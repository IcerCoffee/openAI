//
//  Constants.swift
//  Gateway_2_0
//
//  Created by zuo on 2020/7/16.
//  Copyright © 2020 Mile. All rights reserved.
//

import Foundation

let KSafeAreaBottomHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0

struct UOConstants {
    static let clientId = "1001000001"
    static let userPolicy = "https://iotpservice.smartont.net/web/protocol/app_privacy_ios_20240328.html"
    static let ttPolicy = "https://iotpservice.smartont.net/web/protocol/tongtong_privacy_2025_05_06.html"
    static let bundleId = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    static let phoneModel = UIDevice.current.model
    static let navBarH = getNavigationBarHeight()
    
    static let statusBarH = UIApplication.shared.statusBarFrame.height
    static let screenW = UIScreen.main.bounds.width
    static let screenH = UIScreen.main.bounds.height
    #if __IPHONE_11_0
    static let screenSafeArea = APP_Window!.safeAreaInsets
    #else
    static let screenSafeArea = UIEdgeInsets(top: (screenH >= 812 ? 44 : 20), left: 0, bottom: (screenH >= 812 ? 34 : 0), right: 0)
    #endif
    static let systemVersion = UIDevice.current.systemVersion
    static let colorThemeOld = UIColor.init(red: 0, green: 138/255.0, blue: 1, alpha: 1)
    static let colorTheme = UIColor.init(red: 230/255.0, green: 0/255.0, blue: 39/255.0, alpha: 1)
    static let colorBg = UIColor.init(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    static let colorLine = UIColor.init(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    static let color51 = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    static let color102 = UIColor.init(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
    static let color153 = UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
    static let colorDelete = UIColor.init(red: 1, green: 58/255.0, blue: 46/255.0, alpha: 1)
    static func getAccessToken() -> String {
       return UserDefaults.standard.string(forKey: "AccessToken")!
    }
    static func WiFiPassword(_ ssid: String) -> String {
        return UserDefaults.standard.string(forKey: "WiFi_\(ssid)") ?? ""
    }
    static func saveWiFi(_ ssid: String,_ password: String){
        UserDefaults.standard.set(password, forKey: "WiFi_\(ssid)")
        UserDefaults.standard.synchronize()
    }
    static public func getMacAddress() -> String{
        let index  = Int32(if_nametoindex("en0"))
        let bsdData = "en0".data(using: .utf8)!
        var mib : [Int32] = [CTL_NET,AF_ROUTE,0,AF_LINK,NET_RT_IFLIST,index]
        var len = 0;
        if sysctl(&mib,UInt32(mib.count), nil, &len,nil,0) < 0 {
            print("Error: could not determine length of info data structure ")
            return "00:00:00:00:00:00"
        }
        var buffer = [CChar].init(repeating: 0, count: len)
        if sysctl(&mib, UInt32(mib.count), &buffer, &len, nil, 0) < 0 {
            print("Error: could not read info data structure");
            return "00:00:00:00:00:00"
        }
        let infoData = NSData(bytes: buffer, length: len)
        var interfaceMsgStruct = if_msghdr()
        infoData.getBytes(&interfaceMsgStruct, length: MemoryLayout.size(ofValue: if_msghdr()))
        let socketStructStart = MemoryLayout.size(ofValue: if_msghdr()) + 1
        let socketStructData = infoData.subdata(with: NSMakeRange(socketStructStart, len - socketStructStart))
        let rangeOfToken = socketStructData.range(of: bsdData, options: NSData.SearchOptions(rawValue: 0), in: Range.init(uncheckedBounds: (0, socketStructData.count)))
        let start = rangeOfToken?.count ?? 0 + 3
        let end = start + 6
        let range1 = start..<end
        var macAddressData = socketStructData.subdata(in: range1)
        let macAddressDataBytes: [UInt8] = [UInt8](repeating: 0, count: 6)
        macAddressData.append(macAddressDataBytes, count: 6)
        let macaddress = String.init(format: "%02X:%02X:%02X:%02X:%02X:%02X", macAddressData[0], macAddressData[1], macAddressData[2],
                                     macAddressData[3], macAddressData[4], macAddressData[5])
        return macaddress
    }
    
    /// 获取当前导航栏高度（包括状态栏高度）
       static func getNavigationBarHeight() -> CGFloat {
           guard let navigationController = getCurrentNavigationController() else {
               return 0
           }
           
           let navigationBarHeight = navigationController.navigationBar.frame.height
           let statusBarHeight = UIApplication.shared.statusBarFrame.height
           
           return navigationBarHeight + statusBarHeight
       }
       
       /// 获取当前导航栏高度（不包括状态栏高度）
       static func getNavigationBarHeightOnly() -> CGFloat {
           guard let navigationController = getCurrentNavigationController() else {
               return 0
           }
           
           return navigationController.navigationBar.frame.height
       }
       
       /// 获取当前导航控制器
       private static func getCurrentNavigationController() -> UINavigationController? {
           guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
               return nil
           }
           
           // 从根视图控制器开始查找
           return findNavigationController(from: rootViewController)
       }
       
       /// 递归查找导航控制器
       private static func findNavigationController(from viewController: UIViewController) -> UINavigationController? {
           if let navigationController = viewController as? UINavigationController {
               return navigationController
           }
           
           if let tabBarController = viewController as? UITabBarController {
               if let selected = tabBarController.selectedViewController {
                   return findNavigationController(from: selected)
               }
           }
           
           if let presented = viewController.presentedViewController {
               return findNavigationController(from: presented)
           }
           
           return viewController.navigationController
       }
    
}

