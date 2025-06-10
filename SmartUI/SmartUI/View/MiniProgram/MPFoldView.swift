//
//  MPFoldView.swift
//  SmartUI
//
//  Created by why on 2025/4/15.
//
import UIKit
import SnapKit


/// MARK: - MPFoldView: 折叠／展开视图封装
class MPFoldView: UIView {
    
    /// 定义折叠状态：folded - 仅显示头部；expanded - 显示头部 + 内容
    enum FoldState {
        case folded
        case expanded
    }
    
    /// 状态变化的回调，通知外部父视图刷新布局
    var onFoldStateChanged: ((FoldState) -> Void)?
    
    /// 当前状态，状态切换时自动更新UI及高度
    var state: FoldState = .folded {
        didSet {
            updateUIForState(animated: true)
            onFoldStateChanged?(state)
        }
    }
    
    /// 头部视图及其子控件
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    /// 内容视图（承载列表）及内部 StackView 布局
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    
    /// 数据模型（每行数据包含标题与描述）
    struct RowModel {
        let title: String
        let description: String
    }
    
    /// 外部传入列表数据，设置后自动刷新列表
    var rowModels: [RowModel] = [] {
        didSet {
            updateContent()
        }
    }
    
    /// 内容视图高度约束（用于控制折叠/展开时的高度变化）
    private var contentViewHeightConstraint: Constraint?
    
    /// 头部视图固定高度
    private let headerHeight: CGFloat = 50
    
    // MARK: - 初始化方法
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI 初始化
    private func setupUI() {
        // 整体白色背景、8圆角
        backgroundColor = UIColor(hexString: "#FFFFFF")
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // 添加头部视图
        addSubview(headerView)
        headerView.backgroundColor = .clear
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        // 头部左侧标题
        titleLabel.textColor = UIColor(hexString: "#000000")
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        // 头部右侧箭头图标（初始状态为 "mp_arrow"）
        arrowImageView.image = UIImage(named: "mp_arrow")
        arrowImageView.contentMode = .scaleAspectFit
        headerView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 头部添加点击手势，点击切换折叠状态
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tapGesture)
        
        // 添加内容视图并设置约束：
        // 1、顶部紧贴头部视图底部
        // 2、左右与父视图对齐
        // 3、通过高度约束控制内容视图高度，折叠时设为 0，高度 = 展开时内容视图的自适应高度
        // 4、底部约束与父视图绑定，使整个 MPFoldView 的高度等于 headerHeight + 内容高度
        addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            contentViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview()
        }
        
        // 使用垂直 stackView 布局列表数据，整体内容留白 16
        contentStackView.axis = .vertical
        contentStackView.spacing = 15
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - 列表数据更新
    /// 更新列表内容（每一行展示为左右结构：左标题、右描述）
    private func updateContent() {
        // 清除旧数据视图
        contentStackView.arrangedSubviews.forEach { subview in
            contentStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // 根据数据依次创建行视图并加入 stackView
        for model in rowModels {
            let rowView = createRowView(model: model)
            contentStackView.addArrangedSubview(rowView)
        }
        
        // 如果当前为展开状态，刷新高度约束
        if state == .expanded {
            updateContentHeight(animated: false)
        }
    }
    
    /// 每一行视图（标题与描述在同一行显示，左右结构）
    private func createRowView(model: RowModel) -> UIView {
        let row = UIView()
        
        let rowTitleLabel = UILabel()
        rowTitleLabel.text = model.title
        rowTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        rowTitleLabel.textColor = UIColor(hexString: "#333333")
        // 提高标题水平抗拉伸优先级
        rowTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        row.addSubview(rowTitleLabel)
        rowTitleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        let rowDescLabel = UILabel()
        rowDescLabel.text = model.description
        rowDescLabel.font = UIFont.systemFont(ofSize: 13)
        rowDescLabel.textColor = UIColor(hexString: "#666666")
        rowDescLabel.textAlignment = .right
        // 降低描述标签的水平抗拉伸优先级，让其靠右对齐
        rowDescLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        row.addSubview(rowDescLabel)
        rowDescLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualTo(rowTitleLabel.snp.trailing).offset(8)
        }
        return row
    }
    
    // MARK: - 交互动作
    @objc private func headerTapped() {
        toggleFoldState()
    }
    
    /// 内部或外部调用切换状态
    func toggleFoldState() {
        state = (state == .folded) ? .expanded : .folded
    }
    
    // MARK: - UI & 高度更新（带动画）
    private func updateUIForState(animated: Bool) {
        // 根据状态更新头部箭头图片（"mp_arrow" 或 "mp_arrow_down"）
        let newImageName = (state == .folded) ? "mp_arrow" : "mp_arrow_down"
        arrowImageView.image = UIImage(named: newImageName)
        
        if animated {
            self.layoutIfNeeded()
            updateContentHeight(animated: false)
        } else {
            updateContentHeight(animated: false)
        }
    }
    
    /// 更新内容视图高度约束：展开时计算内容自适应高度，折叠时高度为0
    private func updateContentHeight(animated: Bool) {
        if state == .expanded {
            // 强制布局，计算内容的实际高度（内容StackView + 16*2边距）
            contentView.layoutIfNeeded()
            let contentSize = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            let desiredHeight = contentSize.height + 32  // 16 上下边距
            contentViewHeightConstraint?.update(offset: desiredHeight)
        } else {
            contentViewHeightConstraint?.update(offset: 0)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}
