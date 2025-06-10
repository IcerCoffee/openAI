//
//  VoiceRecorderTipsView.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//
// VoiceRecorderTipsView.swift
import UIKit
import SnapKit

/// 录音提示视图
class TTVoiceRecorderTipsView: UIView {
    /// RecorderView 定义的事件类型
    enum RecorderEvent {
        case touchesBegan, touchesInside, touchesOutside, touchesEnded, touchesCancelled
    }

    /// 顶部阴影图
    private let shadowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "mp_voice_shadow"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    /// 状态文字标签
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textAlignment = .center
        l.text = ""
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hexString: "#FFFFFF").withAlphaComponent(0.9)
        clipsToBounds = false
        isHidden = true

        // 添加阴影图片和文字
        addSubview(shadowImageView)
        addSubview(statusLabel)

        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(shadowImageView.snp.bottom)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().inset(8)
        }
        
        shadowImageView.snp.makeConstraints { make in
            make.bottom.equalTo(statusLabel.snp.top).offset(-20)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

       
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 外部调用，传入 RecorderView 事件，由自己处理显示/隐藏和文字
    func handle(event: RecorderEvent) {
        switch event {
        case .touchesBegan:
            isHidden = false
            updateStatus(isInside: true)
        case .touchesInside:
            updateStatus(isInside: true)
        case .touchesOutside:
            updateStatus(isInside: false)
        case .touchesEnded, .touchesCancelled:
            isHidden = true
        }
    }

    /// 根据是否在录音区域内更新提示文字和颜色
    private func updateStatus(isInside: Bool) {
        if isInside {
            statusLabel.text = "松手发送 上移取消"
            statusLabel.textColor = UIColor(hexString: "#666666")
        } else {
            statusLabel.text = "松手取消"
            statusLabel.textColor = UIColor(hexString: "#E60027")
        }
    }
}

// 将 VoiceRecorderView.Event 转换为 RecorderEvent
extension TTVoiceRecorderTipsView.RecorderEvent {
    init(_ e: VoiceRecorderView.Event) {
        switch e {
        case .touchesBegan:    self = .touchesBegan
        case .touchesInside:   self = .touchesInside
        case .touchesOutside:  self = .touchesOutside
        case .touchesEnded:    self = .touchesEnded
        case .touchesCancelled:self = .touchesCancelled
        }
    }
}

