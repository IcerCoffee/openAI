import UIKit
import SnapKit
import SkeletonView  // 第三方骨架屏 SDK（确保已集成）

class MPInformationVC: UOTopBarViewController, UITextViewDelegate {

    // MARK: - 页面主要视图
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let bottomCardView = UIView()
    private let enterButton = UIButton()
    
    private let privacyView = UIView()
    private let statementView = UIView()
    private let foldView = MPFoldView(title: "主体信息")
    
    // MARK: - 顶部图标+标题+描述（通过接口获取数据）
    private let topStack = UIStackView()
    private let iconImageView = UIImageView()
    private let pageTitleLabel = UILabel()
    private let pageDescLabel = UILabel()
    
    // MARK: - 服务声明数据（通过接口获取数据）
    private let statementBgView = UIView() // 包含圆角背景
    private let statementTitleLabel = UILabel()
    private let statementContentLabel = UILabel()
    
    // 用于协调数据加载完成后隐藏骨架屏
    private let loadGroup = DispatchGroup()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#F8F8F8")
        
        // 开启骨架屏效果（需要保证相关视图支持骨架效果）
        view.isSkeletonable = true
        contentView.isSkeletonable = true
        
        setupBottomCard()
        setupScrollView()
        setupContent()
        setupInfoSection()
        setupPrivacySection()
        setupStatementSection()
        
        // 开始显示骨架屏
        contentView.showAnimatedSkeleton()
        
        // 模拟接口获取数据进行填充，利用 DispatchGroup 统一管理数据加载
        loadGroup.enter()
        loadTopContentData {
            self.loadGroup.leave()
        }
        
        loadGroup.notify(queue: .main) {
            // 数据加载完成后隐藏骨架屏
            self.contentView.hideSkeleton()
        }
    }
    
    // MARK: - 布局构建
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.isSkeletonable = true
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupBottomCard() {
        view.addSubview(bottomCardView)
        bottomCardView.backgroundColor = .white
        bottomCardView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        enterButton.setTitle("进入小程序", for: .normal)
        enterButton.layer.cornerRadius = 22
        enterButton.clipsToBounds = true
        enterButton.setBackgroundImage(UIImage(named: "mp_button_next"), for: .normal)
        enterButton.backgroundColor = UIColor(hexString: "#E60027")
        bottomCardView.addSubview(enterButton)
        enterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: 315, height: 44))
        }
    }
    
    private func setupContent() {
        // 配置顶部图标+标题+描述区域（模拟接口获取数据）
        topStack.axis = .horizontal
        topStack.spacing = 10
        topStack.alignment = .center
        topStack.isSkeletonable = true

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.isSkeletonable = true
        iconImageView.snp.makeConstraints { $0.size.equalTo(CGSize(width: 40, height: 40)) }
        topStack.addArrangedSubview(iconImageView)

        // 配置 pageTitleLabel
        pageTitleLabel.font = .systemFont(ofSize: 18)
        pageTitleLabel.textColor = UIColor(hexString: "#333333")
        pageTitleLabel.isSkeletonable = false  // 不让骨架层影响 intrinsicContentSize
        // 添加垂直方向的抱紧和压缩优先级
        pageTitleLabel.setContentHuggingPriority(.required, for: .vertical)
        pageTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        topStack.addArrangedSubview(pageTitleLabel)
        
        contentView.addSubview(topStack)
        topStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16) // 添加右侧约束
        }
        
        // 顶部描述 Label 设置行间距（在 loadTopContentData 中设置）
        pageDescLabel.font = .systemFont(ofSize: 13)
        pageDescLabel.textColor = UIColor(hexString: "#333333")
        pageDescLabel.numberOfLines = 0
        pageDescLabel.isSkeletonable = true
        contentView.addSubview(pageDescLabel)
        pageDescLabel.snp.makeConstraints { make in
            make.top.equalTo(topStack.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 添加折叠视图（数据依然本地赋值）
        contentView.addSubview(foldView)
        foldView.rowModels = [
            MPFoldView.RowModel(title: "开发者主体", description: "91110302788601580P"),
            MPFoldView.RowModel(title: "社会统一信用代码", description: "联通在线信息科技有限公司"),
            MPFoldView.RowModel(title: "服务类目", description: "其他"),
            MPFoldView.RowModel(title: "版本更新时间", description: "2025年3月1日")
        ]
        foldView.onFoldStateChanged = { newState in
            print("折叠视图状态已切换为：\(newState)")
        }
        foldView.snp.makeConstraints { make in
            make.top.equalTo(pageDescLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(pageDescLabel)
        }
    }

    
    private func setupInfoSection() {
        // 折叠视图中的信息已在 setupContent 中构建
    }
    
    private func setupPrivacySection() {
        contentView.addSubview(privacyView)
        let bgView = roundedBox()
        privacyView.addSubview(bgView)
        
        let titleLabel = UILabel()
        titleLabel.text = "服务隐私及数据显示"
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(hexString: "#000000")
        
        // 使用 UITextView 以支持点击事件及设置行间距
        let contentTextView = UITextView()
        contentTextView.font = .systemFont(ofSize: 13)
        contentTextView.textColor = UIColor(hexString: "#333333")
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.backgroundColor = .clear
        contentTextView.delegate = self
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.isSkeletonable = true
        
        let text = NSMutableAttributedString(string: "开发者严格按照《联通智家APP用户隐私政策》《小程序补充说明》处理你的个人信息，如你发现开发者不当处理你的个人信息，可进行投诉。")
        // 设置行距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        text.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))
        // 添加链接属性用于点击事件识别
        let policyRange = (text.string as NSString).range(of: "《联通智家APP用户隐私政策》")
        let explanationRange = (text.string as NSString).range(of: "《小程序补充说明》")
        text.addAttribute(.link, value: "privacy://policy", range: policyRange)
        text.addAttribute(.link, value: "privacy://explanation", range: explanationRange)
        // 设置默认与链接的文字颜色
        text.addAttribute(.foregroundColor, value: UIColor(hexString: "#333333"), range: NSMakeRange(0, text.length))
        text.addAttribute(.foregroundColor, value: UIColor(hexString: "#E60027"), range: policyRange)
        text.addAttribute(.foregroundColor, value: UIColor(hexString: "#E60027"), range: explanationRange)
        contentTextView.attributedText = text
        contentTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "#E60027")
        ]
        
        bgView.addSubview(titleLabel)
        bgView.addSubview(contentTextView)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
        
        privacyView.snp.makeConstraints { make in
            make.top.equalTo(foldView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    // UITextViewDelegate：处理点击链接事件
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "privacy" {
            if URL.host == "policy" {
                // 处理点击《联通智家APP用户隐私政策》
                print("点击了《联通智家APP用户隐私政策》")
            } else if URL.host == "explanation" {
                // 处理点击《小程序补充说明》
                print("点击了《小程序补充说明》")
            }
            return false
        }
        return true
    }
    
    private func setupStatementSection() {
        contentView.addSubview(statementView)
        let bgView = roundedBox()
        bgView.isSkeletonable = true
        statementView.addSubview(bgView)
        
        // 使用属性构建服务声明标题及内容（数据由模拟接口传入）
        statementTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statementTitleLabel.textColor = UIColor(hexString: "#333333")
        statementTitleLabel.text = "服务声明"
        statementTitleLabel.isSkeletonable = true
        bgView.addSubview(statementTitleLabel)
        
        statementContentLabel.font = .systemFont(ofSize: 13)
        statementContentLabel.textColor = UIColor(hexString: "#333333")
        statementContentLabel.numberOfLines = 0
        statementContentLabel.isSkeletonable = true
        let tipsString = "本服务由开发者向联通用户提供，开发者对本服务信息内容、数据资料及其运营行为等的真实性、合法性及其有效性承担全部责任。\n联通智家APP小程序开发开放平台向开发者提供技术支持服务。"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedContent = NSAttributedString(string: tipsString, attributes: [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor(hexString: "#333333"),
            .font: UIFont.systemFont(ofSize: 13)
        ])
        statementContentLabel.attributedText = attributedContent

        bgView.addSubview(statementContentLabel)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statementTitleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
        }
        
        statementContentLabel.snp.makeConstraints { make in
            make.top.equalTo(statementTitleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(12)
        }
        
        statementView.snp.makeConstraints { make in
            make.top.equalTo(privacyView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(statementView.snp.bottom).offset(20)
        }
    }
    
    private func roundedBox() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }
    
    // MARK: - 模拟接口数据及加载
    
    struct TopContentModel {
        let iconName: String
        let title: String
        let description: String
    }
    
    struct StatementModel {
        let title: String
        let content: String
    }
    
    private func loadTopContentData(completion: (() -> Void)? = nil) {
        // 模拟异步接口调用，加载过程中骨架屏会显示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let model = TopContentModel(iconName: "mp_tempIcon",
                                        title: "智家通通",
                                        description: "智家通通是中国联通智家业务的融合载体，集成多种智家服务与AI能力，为用户打造更智能、更便捷、更个性化的一体化智慧家庭体验。")
            // 设置图标及标题
            self.iconImageView.image = UIImage(named: model.iconName)
            self.pageTitleLabel.attributedText = NSAttributedString(string: model.title)
            
            // 为头部描述文本添加行间距（lineSpacing = 5）
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            let attributedDesc = NSAttributedString(string: model.description, attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor(hexString: "#333333"),
                .font: UIFont.systemFont(ofSize: 13)
            ])
            self.pageDescLabel.attributedText = attributedDesc
            completion?()
        }
    }

}
