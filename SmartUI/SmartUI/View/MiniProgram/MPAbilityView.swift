import UIKit
import SnapKit

enum PopupItem: Int, CaseIterable {
    case collect
    case addToDekTop
    case reboot

    var title: String {
        switch self {
        case .collect: return "收藏"
        case .addToDekTop: return "添加到桌面"
        case .reboot: return "重新进入"
        }
    }

    var normalIcon: UIImage {
        switch self {
        case .collect: return UIImage(named: "mp_collect")!
        case .addToDekTop: return UIImage(named: "mp_addToDesktop")!
        case .reboot: return UIImage(named: "mp_reboot")!
        }
    }

    var selectedIcon: UIImage? {
        switch self {
        case .collect: return UIImage(named: "mp_collect_selected")
        default: return nil
        }
    }
}

class MPAbilityView: UIView {
    private let backgroundView = UIView()
    private let cardView = UIView()
    private let headerView = UIView()
    private let scrollView = UIScrollView()
    private let itemContainer = UIView()
    private let cancelButton = UIButton()

    private var isCollected = false
    private var collectItemView: UIView?

    var onItemTapped: ((PopupItem) -> Void)?
    var onHeaderTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func show(onItemTapped: ((PopupItem) -> Void)? = nil,
                     onHeaderTapped: (() -> Void)? = nil) {
        guard let window = getKeyWindow() else {return}
        let popup = MPAbilityView()
        popup.onItemTapped = onItemTapped
        popup.onHeaderTapped = onHeaderTapped
        popup.frame = window.bounds  // ✅ 关键修复点
        window.addSubview(popup)
        popup.showWithAnimation()
    }


    private func setupViews() {
        backgroundColor = .clear

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(backgroundView)

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true
        addSubview(cardView)

        // Header
        let headerImage = UIImageView(image: UIImage(named: "mp_tempIcon"))
        let headerTitle = UILabel()
        headerTitle.text = "智家通通"
        headerTitle.font = UIFont.systemFont(ofSize: 15)
        headerTitle.textColor = .black

        let headerDesc = UILabel()
        headerDesc.text = "联通在线信息科技有限公司"
        headerDesc.font = UIFont.systemFont(ofSize: 12)
        headerDesc.textColor = UIColor(hex: "#999999")

        let textStack = UIStackView(arrangedSubviews: [headerTitle, headerDesc])
        textStack.axis = .vertical
        textStack.spacing = 4

        headerView.addSubview(headerImage)
        headerView.addSubview(textStack)
        cardView.addSubview(headerView)

        headerImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        textStack.snp.makeConstraints { make in
            make.left.equalTo(headerImage.snp.right).offset(12)
            make.centerY.equalTo(headerImage)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView.addGestureRecognizer(tap)
        headerView.isUserInteractionEnabled = true

        // Items
        scrollView.showsHorizontalScrollIndicator = false
        cardView.addSubview(scrollView)
        scrollView.addSubview(itemContainer)

        // Cancel Button
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.backgroundColor = .white
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        cardView.addSubview(cancelButton)

        setupItems()
    }

    private func setupLayout() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }


        cardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(64)
        }

        itemContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(safeBottomInset > 0 ? safeBottomInset : 12)
        }
    }

    private func setupItems() {
        var lastView: UIView? = nil

        for item in PopupItem.allCases {
            let itemView = UIView()
            itemView.tag = item.rawValue

            let imageView = UIImageView(image: item.normalIcon)
            imageView.contentMode = .scaleAspectFit

            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .center

            itemView.addSubview(imageView)
            itemView.addSubview(titleLabel)

            imageView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 48, height: 48))
            }

            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(4)
                make.left.right.bottom.equalToSuperview()
            }

            itemContainer.addSubview(itemView)

            itemView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(64)
                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(12)
                } else {
                    make.left.equalToSuperview().offset(12)
                }
            }

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            itemView.addGestureRecognizer(tap)

            if item == .collect {
                collectItemView = itemView
            }

            lastView = itemView
        }

        if let last = lastView {
            itemContainer.snp.makeConstraints { make in
                make.right.equalTo(last.snp.right).offset(24)
            }
        }
    }

    private func showWithAnimation() {
        backgroundView.alpha = 0
        cardView.transform = CGAffineTransform(translationX: 0, y: 300)

        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.cardView.transform = .identity
        }
    }

    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: 300)
        }) { _ in
            self.removeFromSuperview()
        }
    }

    @objc private func headerTapped() {
        onHeaderTapped?()
        dismiss()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let item = PopupItem(rawValue: view.tag) else { return }

        if item == .collect {
            isCollected.toggle()
            updateCollectItemViewWithAnimation()
            return;
        }

        onItemTapped?(item)
        dismiss()
    }

    private func updateCollectItemViewWithAnimation() {
        guard let collectView = collectItemView,
              let imageView = collectView.subviews.first(where: { $0 is UIImageView }) as? UIImageView else { return }

        imageView.image = isCollected ? PopupItem.collect.selectedIcon : PopupItem.collect.normalIcon

        imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 6,
                       options: [.curveEaseInOut],
                       animations: {
            imageView.transform = .identity
        }, completion: nil)
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

    
}

// MARK: - UIColor(hex:) 工具扩展
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") { hexSanitized.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
