import UIKit
import SnapKit

/// 提示类型枚举
public enum MSTipsType {
    case offline        // 网络离线
    case banned         // 账号封禁
    case upgrade        // 升级提示
    case authorization  // 授权确认
    // 可根据需求继续添加其他类型
}

/// 提示弹窗视图
public class MPTipsView: UIView {
    
    // MARK: - 子视图
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let confirmButton = UIButton(type: .custom)
    private let cancelButton = UIButton(type: .custom)
    
    // MARK: - 回调
    /// 确认按钮点击回调
    public var onConfirm: (() -> Void)?
    /// 取消按钮点击回调
    public var onCancel: (() -> Void)?
    
    // MARK: - 配置数据
    private let type: MSTipsType
    private var showCancel: Bool = false
    
    // MARK: - 初始化
    public init(type: MSTipsType) {
        self.type = type
        super.init(frame: .zero)
        setupUI()
        applyType(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 构建
    private func setupUI() {
        guard let window = getKeyWindow() else {return}
        frame = window.bounds
        
        // 背景覆盖
        backgroundView.backgroundColor = UIColor(hexString: "#000000").withAlphaComponent(0.7)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 弹窗卡片
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        // 图标
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        // 标题
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = UIColor(hexString: "#333333")
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 描述
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor(hexString: "#666666")
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 确认按钮
        confirmButton.setBackgroundImage(UIImage(named: "mp_button_next"), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        containerView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // 取消按钮
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        containerView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(12)
            make.left.right.equalTo(confirmButton)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 默认隐藏取消按钮
        cancelButton.isHidden = true
    }
    
    // MARK: - 根据类型应用内容
    private func applyType(_ type: MSTipsType) {
        switch type {
        case .offline:
            iconImageView.image = UIImage(named: "mp_tips_more")
            titleLabel.text = "温馨提示"
            descriptionLabel.text = "此小程序已下线\n去看看其他小程序吧~"
            confirmButton.setTitle("确定", for: .normal)
            showCancel = false
        case .banned:
            iconImageView.image = UIImage(named: "mp_tips_banned")
            titleLabel.text = "账号已封禁"
            descriptionLabel.text = "如有疑问请联系客服"
            confirmButton.setTitle("确定", for: .normal)
            showCancel = false
        case .upgrade:
            iconImageView.image = UIImage(named: "mp_tips_upgrade")
            titleLabel.text = "版本需要升级"
            descriptionLabel.text = "请前往 App Store 更新到最新版本"
            confirmButton.setTitle("确定", for: .normal)
            showCancel = false
        case .authorization:
            iconImageView.image = UIImage(named: "mp_tips_more")
            titleLabel.text = "授权提示"
            descriptionLabel.text = "服务需要授权登录账号信息，是否授权？"
            confirmButton.setTitle("确定", for: .normal)
            showCancel = true
        }
        cancelButton.isHidden = !showCancel
    }
    
    // MARK: - 动画显示与隐藏
    public func show() {
        guard let window = getKeyWindow() else {return}
        window.addSubview(self)
        backgroundView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
            self.backgroundView.alpha = 1
            self.containerView.transform = .identity
        }, completion: nil)
    }
    
    public func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundView.alpha = 0
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - 按钮事件
    @objc private func confirmTapped() {
        onConfirm?()
        dismiss()
    }
    
    @objc private func cancelTapped() {
        onCancel?()
        dismiss()
    }
    
    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            // iOS 13+ 多 scene 支持
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })
        } else {
            // iOS 12 及以下
            return UIApplication.shared.keyWindow
        }
    }

}
