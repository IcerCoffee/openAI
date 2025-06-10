//
//  TTInputView.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//

import UIKit
import SnapKit

class TTInputView: UIView {

    /// 点击语音按钮的回调
    var onVoiceButtonTap: (() -> Void)?

    // MARK: - 子视图

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        // 内边框
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        // 阴影
        v.layer.shadowColor = UIColor(hexString: "#000000").cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 4, height: 8)
        v.layer.shadowRadius = 4
        return v
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.attributedPlaceholder = NSAttributedString(
            string: "任何问题，通通搞定",
            attributes: [.foregroundColor: UIColor(hexString: "#CCCCCC")]
        )
        tf.tintColor = UIColor(hexString: "#E60027")
        return tf
    }()

    private let voiceButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "mp_voice_keyboard"), for: .normal)
        return btn
    }()

    private let promptLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "内容由AI生成，谨慎采纳"
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.textColor = UIColor(hexString: "#ACAFBD")
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        setupUI()
    }

    // MARK: - 固定高度

    override var intrinsicContentSize: CGSize {
        // 输入框 52 高 + 上下间距 10 + 提示 11 + 5 额外间距
        return CGSize(width: UIView.noIntrinsicMetric, height: 52 + 10 + 11 + 5)
    }

    // MARK: - 布局

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(textField)
        containerView.addSubview(voiceButton)
        addSubview(promptLabel)

        // containerView：左右 15、顶部 0、高度 52
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(52)
        }

        // 文本输入框：左 10，顶底贴齐，右边至按钮左侧 10
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(voiceButton.snp.left).offset(-10)
        }

        // 切换按钮：24×24，右 10，垂直居中
        voiceButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }

        // 提示 Label：距离输入框底部 10，水平居中
        promptLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 按钮点击回调
        voiceButton.addTarget(self, action: #selector(handleVoiceTap), for: .touchUpInside)
    }

    @objc private func handleVoiceTap() {
        onVoiceButtonTap?()
    }
}
