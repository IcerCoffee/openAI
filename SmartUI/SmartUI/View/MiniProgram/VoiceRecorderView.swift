//
//  VoiceRecorderView.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//
import UIKit
import SnapKit
import AVFoundation

/// 语音录制及频谱组件，支持按住录音、移出取消、松开结束
class VoiceRecorderView: UIView {
    /// 录音结束回调：path 为 nil 则表示取消或失败
    var onFinishRecording: ((String?) -> Void)?
    /// 状态事件回调
    var onEvent: ((Event) -> Void)?
    /// 点击键盘按钮回调
    var onKeyboardTap: (() -> Void)?
    private var audioURL: URL?
    enum Event {
        case touchesBegan, touchesInside, touchesOutside, touchesEnded, touchesCancelled
    }
    
    // MARK: - UI
    
    private let recordOverlay: UIButton = {
        let v = UIButton()
        v.layer.cornerRadius = 8
        v.isHidden = true
        v.isUserInteractionEnabled = false
        v.setBackgroundImage(UIImage(named: "mp_voice_remove"), for: .selected)
        v.setBackgroundImage(UIImage(named: "mp_voice_record"), for: .normal)
        return v
    }()
    
    private let hintLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textAlignment = .center
        l.textColor = UIColor(hexString: "#333333")
        l.text = "按住说话"
        return l
    }()
    
    private lazy var keyboardButton: UIButton = {
        let b = UIButton()
        b.setBackgroundImage(UIImage(named: "mp_voice_keyboard"), for: .normal)
        b.addTarget(self, action: #selector(keboardTap), for: .touchUpInside)
        return b
    }()
    
    private var barHeightConstraints: [Constraint] = []
    private var baselineFactors: [CGFloat] = []
    
    // MARK: - 录音
    
    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var isRecording = false
    private var isInCancelZone = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - 布局
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        layer.shadowColor = UIColor(hexString: "#000000").cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 4, height: 8)
        layer.shadowRadius = 4
        
        addSubview(recordOverlay)
        recordOverlay.snp.makeConstraints { make in make.edges.equalToSuperview() }
        
        addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in make.center.equalToSuperview() }
        
        // 频谱条
        let barCount = 36, barWidth: CGFloat = 3, spacing: CGFloat = 4
        baselineFactors = (0..<barCount).map { _ in CGFloat.random(in: 0.5...0.95) }
        for i in 0..<barCount {
            let bar = UIView()
            bar.backgroundColor = .white
            bar.layer.cornerRadius = barWidth/2
            recordOverlay.addSubview(bar)
            bar.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(barWidth)
                let x = CGFloat(i - barCount/2) * (barWidth + spacing)
                make.centerX.equalToSuperview().offset(x)
                let h = make.height.equalTo(2).constraint
                barHeightConstraints.append(h)
            }
        }
        
        addSubview(keyboardButton)
        keyboardButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        bringSubviewToFront(hintLabel)
    }
    
    // MARK: - 触摸事件
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        onEvent?(.touchesBegan)
        guard let p = touches.first?.location(in: self), bounds.contains(p) else { return }
        isRecording = true
        hintLabel.isHidden = true
        showRecordingState()
        startRecording()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard isRecording, let p = touches.first?.location(in: self) else { return }
        let inside = bounds.contains(p)
        if inside, isInCancelZone {
            isInCancelZone = false
            showRecordingState()
        } else if !inside, !isInCancelZone {
            isInCancelZone = true
            showCancelState()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onEvent?(.touchesEnded)
        guard isRecording else { return }
        isRecording = false
        hintLabel.isHidden = false
        recordOverlay.isHidden = true
        keyboardButton.isHidden = false
        let save = touches.first.map { bounds.contains($0.location(in: self)) } ?? false
        finishRecording(save: save)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        onEvent?(.touchesCancelled)
        guard isRecording else { return }
        isRecording = false
        hintLabel.isHidden = false
        recordOverlay.isHidden = true
        keyboardButton.isHidden = false
        finishRecording(save: false)
    }
    
    // MARK: - 按键回调
    
    @objc private func keboardTap() {
        onKeyboardTap?()
    }
    
    // MARK: - UI 状态
    
    private func showRecordingState() {
        onEvent?(.touchesInside)
        recordOverlay.isHidden = false
        recordOverlay.isSelected = false
        keyboardButton.isHidden = true
    }
    
    private func showCancelState() {
        onEvent?(.touchesOutside)
        recordOverlay.isHidden = false
        recordOverlay.isSelected = true
        keyboardButton.isHidden = true
    }
    
    // MARK: - 录音流程
    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            session.requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if granted { self.beginRecorder() }
                    else { self.finishRecording(save: false) }
                }
            }
        } catch {
            finishRecording(save: false)
        }
    }
    
    private func beginRecorder() {
        let file = "temp_voice.m4a"
        audioURL = URL(fileURLWithPath: NSTemporaryDirectory() + file)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.12,
                                              target: self,
                                              selector: #selector(updateMeters),
                                              userInfo: nil,
                                              repeats: true)
        } catch {
            finishRecording(save: false)
        }
    }
    
    @objc private func updateMeters() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        let level = max(0, CGFloat((power + 60) / 60))
        let maxH: CGFloat = 36
        let minH: CGFloat = 1
        let threshold: CGFloat = 0.1
        let factor = level < threshold ? 0 : (level - threshold) / (1 - threshold)
        for i in 0..<barHeightConstraints.count {
            let base = baselineFactors[i]
            let random = CGFloat.random(in: 0.4...1.2)
            let h = minH + factor * maxH * base * random
            barHeightConstraints[i].update(offset: h)
        }
        recordOverlay.layoutIfNeeded()
    }
    
    private func finishRecording(save: Bool) {
        meterTimer?.invalidate()
        audioRecorder?.stop()
        onFinishRecording?(save ? audioURL?.absoluteString : nil)
        audioRecorder = nil
        audioURL = nil
    }
}
