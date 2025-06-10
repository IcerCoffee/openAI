//
//  PrivacyAccessStatisticsManager.swift
//  SmartUI
//
//  Created by why on 2025/5/29.
//

import Foundation

// MARK: - 1. 枚举定义，OC 可见
@objc public enum DataType: Int {
    case phone            = 1   // 手机号
    case basicInfo        = 2   // 基本资料
    case realName         = 3   // 实名信息
    case location         = 4   // 位置信息
    case deviceOS         = 5   // 设备操作系统
    case systemVersion    = 6   // 设备系统版本
    case screenResolution = 7   // 屏幕分辨率
    case deviceLanguage   = 8   // 设备语言
    case appName          = 9   // App 名称
    case appVersion       = 10  // App 版本号
    case contacts         = 11  // 通讯录
}

@objc public enum UseObjective: Int {
    case createAccountContact    = 1 // 创建账号，联系用户
    case createAccount           = 2 // 创建账号
    case realNameAuth            = 3 // 实名认证
    case locationEnhanceBrowsing = 4 // 提升浏览体验等
    case adaptDevice             = 5 // 适配你当前设备
    case analytics               = 6 // 分析与统计
    case contactsBackup          = 7 // 通讯录备份、文件分享等
}

@objc public enum UseScene: Int {
    case firstRegister       = 1 // 你首次注册时
    case firstUseFixedPhone  = 2 // 首次使用联通固话开户等
    case duringAppUsage      = 3 // 使用 App 过程中
    case firstLaunch         = 4 // 应用第一次安装启动时
    case afterContactsAuth   = 5 // 用户授权通讯录后
}

// MARK: - 2. 记录模型
@objcMembers
public class PrivacyAccessRecord: NSObject, Codable {
    public let dataType: Int
    public let content: String
    public let useObjective: Int
    public let useScene: Int
    public let collectNum: Int
    public let timestamp: Date

    public init(
        dataType: Int,
        content: String,
        useObjective: Int,
        useScene: Int,
        collectNum: Int,
        timestamp: Date = Date()
    ) {
        self.dataType     = dataType
        self.content      = content
        self.useObjective = useObjective
        self.useScene     = useScene
        self.collectNum   = collectNum
        self.timestamp    = timestamp
    }
}

// MARK: - 3. 分组 Key，自动 Hashable
private struct StatisticKey: Hashable {
    let dataType: Int
    let content: String
    let useObjective: Int
    let useScene: Int
}

// MARK: - 4. 管理单例，OC 可访问
@objcMembers
public final class PrivacyAccessStatisticsManager: NSObject {
    @objc public class var shared: PrivacyAccessStatisticsManager {
        return _shared
    }
    private static let _shared = PrivacyAccessStatisticsManager()

    private let storageKey = "PrivacyAccessRecords"
    private var records: [PrivacyAccessRecord] = []

    /// 默认配置，仅对 location 和 contacts 生效
    private let defaultConfigs: [DataType: (content: String, objective: Int, scene: Int, count: Int)] = [
        .location: ("位置信息", UseObjective.locationEnhanceBrowsing.rawValue, UseScene.duringAppUsage.rawValue, 1),
        .contacts: ("通讯录",    UseObjective.contactsBackup.rawValue,         UseScene.afterContactsAuth.rawValue, 1)
    ]

    private override init() {
        super.init()
        loadRecords()
        cleanOldRecords()
    }

    // MARK: —— 持久化方法 ——
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([PrivacyAccessRecord].self, from: data) {
            records = decoded
        }
    }

    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func cleanOldRecords() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        records.removeAll { $0.timestamp < sevenDaysAgo }
        saveRecords()
    }

    // MARK: —— 核心上报方法 ——

    /// 通用手动触发统计，OC 可调用
    @objc(recordAccessWithDataType:content:useObjective:useScene:collectNum:)
    public func recordAccess(
        dataType: DataType,
        content: String,
        useObjective: Int,
        useScene: Int,
        collectNum: Int = 1
    ) {
        cleanOldRecords()
        let rec = PrivacyAccessRecord(
            dataType: dataType.rawValue,
            content: content,
            useObjective: useObjective,
            useScene: useScene,
            collectNum: collectNum
        )
        records.append(rec)
        saveRecords()
    }

    /// 统一入口：传入枚举即可上报
    @objc public func record(type: DataType) {
        if let cfg = defaultConfigs[type] {
            // 使用默认配置
            recordAccess(
                dataType: type,
                content: cfg.content,
                useObjective: cfg.objective,
                useScene: cfg.scene,
                collectNum: cfg.count
            )
        } else {
            // 非 location/contacts，其他值使用 -1 填充
            recordAccess(
                dataType: type,
                content: "",
                useObjective: -1,
                useScene: -1,
                collectNum: 1
            )
        }
    }

    @objc(accessCountForType:)
    public func accessCount(for type: DataType) -> Int {
        // 先清理超过 7 日的旧数据
        cleanOldRecords()
        // 累加 records 中 dataType 匹配的 collectNum
        return records
            .filter { $0.dataType == type.rawValue }
            .reduce(0) { $0 + $1.collectNum }
    }
    
    
    /// 上报通讯录和位置信息，并仅清空这两类上报成功的数据
    @objc(reportLocationAndContactsWithCompletion:)
    public func reportLocationAndContacts(completion: @escaping (Bool) -> Void) {
        cleanOldRecords()

        // 筛选出只需要上报的两类记录
        let toReport = records.filter {
            $0.dataType == DataType.location.rawValue ||
            $0.dataType == DataType.contacts.rawValue
        }

        guard !toReport.isEmpty else {
            DispatchQueue.main.async { completion(true) }
            return
        }

        // 分组聚合
        let grouped = Dictionary(grouping: toReport) { rec in
            StatisticKey(
                dataType: rec.dataType,
                content: rec.content,
                useObjective: rec.useObjective,
                useScene: rec.useScene
            )
        }

        // 构建 payload
        var payload: [[String: Any]] = []
        for (key, recs) in grouped {
            let total = recs.reduce(0) { $0 + $1.collectNum }
            payload.append([
                "dataType":     key.dataType,
                "content":      key.content,
                "useObjective": key.useObjective,
                "useScene":     key.useScene,
                "collectNum":   total
            ])
        }

        // 模拟网络调用
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let success = true
            if success {
                // 只删除已上报的位置信息和通讯录记录
                let reportedKeys = Set(grouped.keys)
                self.records.removeAll { rec in
                    reportedKeys.contains(
                        StatisticKey(
                            dataType: rec.dataType,
                            content: rec.content,
                            useObjective: rec.useObjective,
                            useScene: rec.useScene
                        )
                    )
                }
                self.saveRecords()
            }
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
