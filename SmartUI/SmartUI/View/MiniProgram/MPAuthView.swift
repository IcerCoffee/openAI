import UIKit
import SnapKit

class MPAuthView: UIView {
    // MARK: - 子视图定义
    private let backgroundView = UIView()
    private let cardView = UIView()

    private let headerView = UIView()
    private let headerIcon = UIImageView()
    private let headerTitle = UILabel()
    private let headerTip = UILabel()

    private let permissionLabel = UILabel()

    private let infoView = UIView()
    private let phoneLabel = UILabel()
    private let descLabel = UILabel()
    private let selectedIcon = UIImageView()

    private let privacyLabel = UILabel()

    private let rejectButton = UIButton()
    private let allowButton = UIButton()

    // 回调定义
    var onReject: (() -> Void)?
    var onAllow: (() -> Void)?

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // 背景
        backgroundColor = .clear
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 卡片
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 15
        cardView.layer.masksToBounds = true
        addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
        }

        // Header
        headerIcon.image = UIImage(named: "mp_tempIcon")
        headerTitle.text = "智家通通"
        headerTitle.font = UIFont.systemFont(ofSize: 15)
        headerTip.text = "申请"
        headerTip.font = UIFont.systemFont(ofSize: 14)
        headerTip.textColor = .gray

        headerView.addSubview(headerIcon)
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerTip)
        cardView.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        headerIcon.snp.makeConstraints { $0.size.equalTo(24); $0.left.centerY.equalToSuperview() }
        headerTitle.snp.makeConstraints { $0.left.equalTo(headerIcon.snp.right).offset(8); $0.centerY.equalToSuperview() }
        headerTip.snp.makeConstraints { $0.left.equalTo(headerTitle.snp.right).offset(8); $0.centerY.equalToSuperview() }

        // 权限描述
        permissionLabel.text = "访问您的登录账号信息"
        permissionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        cardView.addSubview(permissionLabel)
        permissionLabel.snp.makeConstraints { $0.top.equalTo(headerView.snp.bottom).offset(20); $0.left.right.equalToSuperview().inset(16) }

        // 授权信息样式修改
        phoneLabel.text = "155****8888"
        descLabel.text = "联通智家App当前登录号码"
        phoneLabel.font = UIFont.systemFont(ofSize: 15)
        descLabel.font = UIFont.systemFont(ofSize: 12)
        phoneLabel.textColor = UIColor(hexString: "#333333")
        descLabel.textColor = UIColor(hexString: "#999999")
        phoneLabel.numberOfLines = 1
        descLabel.numberOfLines = 1
        selectedIcon.image = UIImage(named: "mp_check")

        let infoTextStack = UIStackView(arrangedSubviews: [phoneLabel, descLabel])
        infoTextStack.axis = .vertical
        infoTextStack.spacing = 4

        infoView.addSubview(infoTextStack)
        infoView.addSubview(selectedIcon)
        cardView.addSubview(infoView)

        infoView.snp.makeConstraints { $0.top.equalTo(permissionLabel.snp.bottom).offset(16); $0.left.right.equalToSuperview().inset(16) }
        infoTextStack.snp.makeConstraints { $0.top.bottom.left.equalToSuperview() }
        selectedIcon.snp.makeConstraints {
//            $0.left.equalTo(infoTextStack.snp.right).offset(8)
            $0.centerY.equalTo(infoTextStack)
            $0.size.equalTo(24)
            $0.right.lessThanOrEqualToSuperview()
        }

        // 协议
        privacyLabel.text = "《用户隐私协议》"
        privacyLabel.textColor = UIColor(hexString: "#666666")
        privacyLabel.font = UIFont.systemFont(ofSize: 13)
        cardView.addSubview(privacyLabel)
        privacyLabel.snp.makeConstraints { $0.top.equalTo(infoView.snp.bottom).offset(16); $0.left.equalToSuperview().inset(16) }

        // 按钮
        rejectButton.setTitle("拒绝", for: .normal)
        rejectButton.setTitleColor(.black, for: .normal)
        rejectButton.layer.cornerRadius = 20
        rejectButton.layer.borderColor = UIColor.gray.cgColor
        rejectButton.layer.borderWidth = 0.5
        rejectButton.backgroundColor = .white

        allowButton.setTitle("允许", for: .normal)
        allowButton.setBackgroundImage(UIImage(named: "mp_button_agree"), for: .normal)
        allowButton.layer.cornerRadius = 20
        allowButton.clipsToBounds = true

        [rejectButton, allowButton].forEach {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            cardView.addSubview($0)
        }

        rejectButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 150, height: 44))
            $0.left.equalToSuperview().inset(32)
            $0.top.equalTo(privacyLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(safeBottomInset>0 ? safeBottomInset:20)
        }

        allowButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 150, height: 44))
            $0.right.equalToSuperview().inset(32)
            $0.centerY.equalTo(rejectButton)
        }

        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)
        allowButton.addTarget(self, action: #selector(allowTapped), for: .touchUpInside)
    }

    private var safeBottomInset: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.windows.first }
                .first?.safeAreaInsets.bottom ?? 0
        } else {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
    }

    private static func getKeyWindow() -> UIWindow? {
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
    
    // MARK: - 展示方法
    static func show(onReject: (() -> Void)? = nil, onAllow: (() -> Void)? = nil) {
        guard let window = getKeyWindow() else {return}
        let authView = MPAuthView(frame: window.bounds)
        authView.onReject = onReject
        authView.onAllow = onAllow
        window.addSubview(authView)

        // 初始位置在底部外
        authView.cardView.transform = CGAffineTransform(translationX: 0, y: authView.cardView.frame.height + 200)
        authView.backgroundView.alpha = 0

        // 动画弹出
        UIView.animate(withDuration: 0.3) {
            authView.cardView.transform = .identity
            authView.backgroundView.alpha = 1
        }
    }

    // MARK: - 回调事件
    @objc private func rejectTapped() {
        onReject?()
        dismiss()
    }

    @objc private func allowTapped() {
        onAllow?()
        dismiss()
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.cardView.transform = CGAffineTransform(translationX: 0, y: self.cardView.frame.height + 200)
            self.backgroundView.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
