// CombinedInputView.swift
// SmartUI
//
// Created by why on 2025/5/19.
//

import UIKit
import SnapKit
import AVFoundation

/// 合并了文本输入和语音录制两种模式，通过 enum Mode 切换样式
class TTCombinedInputView: UIView {
    
    enum Mode {
        case text
        case voice
    }
    
    enum TextInputState {
        case normal
        case fullscreen
    }
    
    enum ViewChangeState {
        case keyboard //键盘变化重新布局
        case action // 点击全屏按钮 重新布局
        case text // 文字换行高度变化 重新布局
        case reset // 发送文字重新布局
    }
    
    // MARK: - 回调
    
//    var onSendText: ((String) -> Void)?
    var onFinishRecording: ((String?) -> Void)?
    var onEvent: ((TTVoiceRecorderTipsView.RecorderEvent) -> Void)?
    var onModeChange: ((Mode) -> Void)?
    var onTextInputStateChange: ((TextInputState) -> Void)?
    var inputHeight = 42.0
    var keyboardHeight = 0.0
    var isSendReset = false
//    var isFromFullScreen = false // 是否通过全屏后 恢复输入框默认状态
    let inputBottomOffset = 28 // 是否通过全屏后 恢复输入框默认状态
    private var audioURL: URL?
    private let viewModel: TTAssistantViewModel
    // MARK: - 容器视图
    enum Event {
        case touchesBegan, touchesInside, touchesOutside, touchesEnded, touchesCancelled
    }
    private let textContainer = UIView()
    private let voiceContainer = UIView()
    
    // MARK: - 文本模式子控件
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .black
        tv.tintColor = UIColor(hexString: "#E60027")
        tv.backgroundColor = .clear
//        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.isScrollEnabled = true
        tv.returnKeyType = .send
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.maximumNumberOfLines = 0  // 不限制行数
        tv.text = "先帝创业未半而中道崩殂，今天下三分，益州疲弊，此诚危急存亡之秋也。然侍卫之臣不懈于内，忠志之士忘身于外者，盖追先帝之殊遇，欲报之于陛下也。诚宜开张圣听，以光先帝遗德，恢弘志士之气；不宜妄自菲薄，引喻失义，以塞忠谏之路也。"
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "任何问题，通通搞定"
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(hexString: "#CCCCCC")
        return lbl
    }()
    
    private let voiceButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "mp_voice_sound"), for: .normal)
        btn.setImage(UIImage(named: "mp_voice_send"), for: .selected)
        return btn
    }()
    
    private let fullscreenButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "tt_input_full"), for: .normal)
        btn.tintColor = UIColor(hexString: "#999999")
        btn.isHidden = true
        return btn
    }()
    
    private let promptLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "内容由AI生成，谨慎采纳"
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = UIColor(hexString: "#ACAFBD")
        return lbl
    }()
    
    // MARK: - 语音模式子控件
    
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
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textAlignment = .center
        l.textColor = UIColor(hexString: "#333333")
        l.text = "按住说话"
        return l
    }()
    
    private let keyboardButton: UIButton = {
        let b = UIButton()
        b.setBackgroundImage(UIImage(named: "mp_voice_keyboard"), for: .normal)
        return b
    }()
    
    private var barHeightConstraints: [Constraint] = []
    private var baselineFactors: [CGFloat] = []
    
    // MARK: - 录音相关
    
    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var isRecording = false
    private var isInCancelZone = false
    
    // MARK: - 当前模式
    
    private(set) var mode: Mode = .voice {
        didSet {
            updateUI()
            onModeChange?(mode)
            invalidateIntrinsicContentSize()
        }
    }
    
    private(set) var textInputState: TextInputState = .normal {
        didSet {
            onTextInputStateChange?(textInputState)
        }
    }
    
    
    /// 指定初始化，必须传入 TTAssistantViewModel
    init(viewModel: TTAssistantViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appDidbecomeActive),
//            name: UIApplication.didBecomeActiveNotification,
//            object: nil)
        
        setupUI()
        updateUI()
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 未实现")
    }
    
    private func setupUI() {
        backgroundColor = .white
        self.layer.cornerRadius = 8
        // —— 添加容器 —— //
        addSubview(promptLabel)
        addSubview(textContainer)
        addSubview(voiceContainer)
        
        textContainer.backgroundColor = .white
        textContainer.layer.cornerRadius = 8
        textContainer.layer.borderWidth = 0.5
        textContainer.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        textContainer.layer.shadowColor = UIColor(hexString: "#000000").cgColor
        textContainer.layer.shadowOpacity = 0.1
        textContainer.layer.shadowOffset = CGSize(width: 4, height: 8)
        textContainer.layer.shadowRadius = 4
        
        voiceContainer.backgroundColor = .white
        voiceContainer.layer.cornerRadius = 8
        voiceContainer.layer.borderWidth = 0.5
        voiceContainer.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        voiceContainer.layer.shadowColor = UIColor(hexString: "#000000").cgColor
        voiceContainer.layer.shadowOpacity = 0.1
        voiceContainer.layer.shadowOffset = CGSize(width: 4, height: 8)
        voiceContainer.layer.shadowRadius = 4
        
        promptLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        textContainer.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(0)
            make.height.greaterThanOrEqualTo(52)
            make.bottom.equalToSuperview().offset(-inputBottomOffset)
        }
        
        voiceContainer.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(0)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-inputBottomOffset)
        }
        
        // —— 文本模式 —— //
        textContainer.addSubview(textView)
        textContainer.addSubview(placeholderLabel)
        textContainer.addSubview(voiceButton)
        textContainer.addSubview(fullscreenButton)
        
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(voiceButton.snp.left).offset(-10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(textView).offset(5)
            make.top.equalTo(17)
        }
        
        voiceButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-11)
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        fullscreenButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(voiceButton.snp.right)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        // —— 语音模式 —— //
        voiceContainer.addSubview(recordOverlay)
        voiceContainer.addSubview(hintLabel)
        voiceContainer.addSubview(keyboardButton)
        
        recordOverlay.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(52)
        }
        
        hintLabel.snp.makeConstraints { make in
            make.center.equalTo(recordOverlay)
        }
        
        keyboardButton.snp.makeConstraints { make in
            make.centerY.equalTo(recordOverlay)
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        // 生成频谱条
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
                let x = CGFloat(i - barCount/2)*(barWidth+spacing)
                make.centerX.equalToSuperview().offset(x)
                let h = make.height.equalTo(2).constraint
                barHeightConstraints.append(h)
            }
        }
        
        // —— 事件绑定 —— //
        voiceButton.addTarget(self, action: #selector(switchToVoice), for: .touchUpInside)
        keyboardButton.addTarget(self, action: #selector(switchToText), for: .touchUpInside)
        fullscreenButton.addTarget(self, action: #selector(inputScaleCilck), for: .touchUpInside)
    }
    
    private func setupTextView() {
        textView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: textView
        )
    }
    
    private func sendMessage(message:String){
        if (textInputState == .fullscreen){
            textInputState = .normal
        }
//        onFinishRecording?(message)
//        self.viewModel.send(with: message)
    }
    
    
    @objc func appWillResignActive(){
        textView.resignFirstResponder()
    }
          
//    @objc func appDidbecomeActive(){
//        textView.becomeFirstResponder()
//    }
           
    // 键盘显示处理
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            print("键盘高度 ： \(keyboardHeight)")
            updateTextInputState(status: .keyboard)
        }
    }

    // 键盘隐藏处理
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        updateTextInputState(status: .keyboard)
    }
    
    // 移除观察者
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 切换模式
    
    @objc private func switchToVoice() {
        if voiceButton.isSelected {
//            if (self.viewModel.isConnecting){
//                WoToast.show(withText:"通通分析中，请等待")
//                textView.resignFirstResponder()
//            }else{
                sendMessage(message: textView.text)
                textView.text = ""
                isSendReset = true
                textDidChange()
//            }
            
        }else{
            mode = .voice
        }
    }
    
    @objc private func switchToText() {
        mode = .text
        textView.becomeFirstResponder()
        textDidChange()
    }
    
    @objc private func inputScaleCilck() {
        textInputState = textInputState == .normal ? .fullscreen : .normal
        toggleFullscreen(isOnlyKeyboardChange:false)
    }
    
    @objc private func toggleFullscreen(isOnlyKeyboardChange : Bool) {
        updateTextInputState(status: .action)
        if (textView.text.isEmpty){
            voiceButton.isSelected = false
            fullscreenButton.isHidden = true
        }
        textDidChange()
    }
    
    // MARK: - 更新 UI

    
    private func updateTextInputState(status : ViewChangeState) {
        
        switch textInputState {
        case .normal:
            fullscreenButton.setImage(UIImage(named: "tt_input_full"), for: .normal)
            placeholderLabel.snp.updateConstraints { make in
                make.top.equalTo(17)
            }
            textView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(8)
            }
            textContainer.snp.updateConstraints { make in
                make.left.equalTo(15)
                make.right.equalToSuperview().offset(-15)
                make.bottom.equalToSuperview().offset(-inputBottomOffset)
            }
            self.snp.updateConstraints{ make in
                make.height.equalTo(35 + self.inputHeight)
                make.bottom.equalToSuperview().inset(adjustBottomSnp())
            }
            
        case .fullscreen:
            fullscreenButton.setImage(UIImage(named: "tt_input_normal"), for: .normal)
            placeholderLabel.snp.updateConstraints { make in
                make.top.equalTo(30)
            }
            textView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(20)
            }
            
            textContainer.snp.updateConstraints { make in
                make.left.right.bottom.equalToSuperview()
            }
            
            self.snp.updateConstraints{ make in
                make.height.equalTo(adjustViewheight())
                make.bottom.equalToSuperview().inset(adjustBottomSnp())
            }
        }
        

        
        
        
        
        
//        switch textInputState {
//        case .normal:
//            promptLabel.isHidden = false
//            fullscreenButton.setImage(UIImage(named: "tt_input_full"), for: .normal)
//            print("高度 ： \(keyboardHeight)")
//            textContainer.snp.updateConstraints { make in
//                make.left.equalTo(15)
//                make.right.equalToSuperview().offset(-15)
//            }
//            if status == .keyboard {
//                self.snp.updateConstraints{ make in
//                    make.height.equalTo(35 + self.inputHeight)
//                    make.bottom.equalToSuperview().inset(adjustBottomSnp())
//                }
//                if (keyboardHeight > 0){ //
//                    print("正常状态 ： 键盘弹出")
//                }else{
//                    print("正常状态 ： 键盘收起")
//                }
//            }else if status == .action{
//                if (keyboardHeight > 0){
//                    self.snp.updateConstraints{ make in
//                        make.height.equalTo(35 + self.inputHeight)
//                        if isFromFullScreen {
//                            make.bottom.equalToSuperview().inset(keyboardHeight-9)
//                            isFromFullScreen = false
//                        }else{
//                            make.bottom.equalToSuperview().inset(0)
//                        }
//                    }
//                    print("有键盘状态 ： 关闭全屏")
//                }else{
//                    self.snp.updateConstraints{ make in
//                        make.height.equalTo(35 + self.inputHeight)
//                        make.bottom.equalToSuperview().inset(adjustBottomSnp())
//                    }
//                    print("无键盘状态状态 ： 关闭全屏")
//                }
//            }else if status == .reset{
//                self.snp.updateConstraints{ make in
//                    make.height.equalTo(35 + self.inputHeight)
//                    make.bottom.equalToSuperview().inset(adjustBottomSnp())
//                }
//            }else{
//                self.snp.updateConstraints{ make in
//                    make.height.equalTo(35 + self.inputHeight)
//                    make.bottom.equalToSuperview().inset(adjustBottomSnp())
//                }
//            }
//        case .fullscreen:
//            promptLabel.isHidden = true
//            fullscreenButton.setImage(UIImage(named: "tt_input_normal"), for: .normal)
//            textContainer.snp.updateConstraints { make in
//                make.left.right.equalToSuperview()
//            }
//            if status == .keyboard {
//                if (keyboardHeight > 0) { // 全屏状态 展开键盘
//                    print("全屏状态 展开键盘")
//                    self.snp.updateConstraints{ make in
//                        make.left.right.equalToSuperview()
//                        make.height.equalTo(adjustViewheight())
//                        make.bottom.equalToSuperview().offset(-keyboardHeight + 35)
//                    }
//                } else { // 全屏状态，收起键盘
//                    print("全屏状态 收起键盘")
//                    isFromFullScreen = true
//                    self.snp.updateConstraints{ make in
//                        make.left.right.equalToSuperview()
//                        make.height.equalTo(adjustViewheight())
//                        make.bottom.equalToSuperview().offset(0)
//                    }
//                }
//            }else if status == .action{
//                self.snp.updateConstraints{ make in
//                    make.left.right.equalToSuperview()
//                    make.height.equalTo(adjustViewheight())
//                    make.bottom.equalToSuperview().offset(0)
//                }
//                if (keyboardHeight > 0) {  // 键盘已抬出 - 点击全屏按钮
//                    print("键盘已抬出 - 点击全屏按钮")
//                }else{ // 键盘未抬出，点击全屏按钮
//                    isFromFullScreen = true
//                    print("键盘未抬出，点击全屏按钮")
//                }
//            }else if status == .reset{
//                if (keyboardHeight > 0) {  // 键盘已抬出 - 点击全屏按钮
//                    print("键盘已抬出 - 点击发送")
//                }else{ // 键盘未抬出，点击全屏按钮
//                    print("键盘未抬出，点击发送")
//                }
//                self.snp.updateConstraints{ make in
//                    make.height.equalTo(35 + self.inputHeight)
//                    make.bottom.equalToSuperview().inset(adjustBottomSnp())
//                }
//            }else{
//                self.snp.updateConstraints{ make in
//                    make.left.right.equalToSuperview()
//                    make.height.equalTo(adjustViewheight())
//                    make.bottom.equalToSuperview().offset(0)
//                }
//            }
//            
//
//        }
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func adjustViewheight() -> Float{
        var viewHeight = UOConstants.screenH - UOConstants.navBarH  - keyboardHeight
        print("高度：\(UOConstants.screenH) - \(UOConstants.statusBarH) - \(keyboardHeight) = \(viewHeight)")
        return Float(viewHeight)
    }
    
    private func adjustBottomSnp() -> Float{
        let bottom:Float;
        if UOConstants.screenSafeArea.bottom > 0 { //刘海屏
            if textInputState == .fullscreen{
                bottom = Float(keyboardHeight > 0 ? keyboardHeight : 0)
            }else{
                bottom = Float(keyboardHeight > 0 ? keyboardHeight : UOConstants.screenSafeArea.bottom)
            }
        }else{ // 非刘海屏
            bottom = Float(keyboardHeight > 0 ? 25 + keyboardHeight : 0 + keyboardHeight)
        }
        return bottom
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if (textInputState == .fullscreen){
            voiceButton.isSelected = true
            voiceButton.alpha = textView.text.isEmpty ? 0.3:1
        }else{
            voiceButton.alpha = 1
            voiceButton.isSelected = !textView.text.isEmpty
        }
        
        // 计算文本行数
        let layoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        // 根据行数显示/隐藏全屏按钮
        fullscreenButton.isHidden = numberOfLines < 4 && textInputState == .normal
        
        // 更新输入框高度
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        print("lines : \(numberOfLines), height:\(newSize.height)")
        let newHeight = min(max(newSize.height, 42), 101)
        if self.inputHeight  < newHeight{
            self.inputHeight = newHeight
            updateTextInputState(status: isSendReset ? .reset : .text)
        } else if self.inputHeight > newHeight {
            self.inputHeight = newHeight
            updateTextInputState(status: isSendReset ? .reset : .text)
        }
        isSendReset = false
    }
    
    
    
    private func updateUI() {
        if mode == .text {
//            textView.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
        }
        textContainer.isHidden = (mode != .text)
        voiceContainer.isHidden = (mode != .voice)
        
    }
    
    // MARK: - 录音触摸事件
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard mode == .voice else { return }
//        if (self.viewModel.isConnecting){
//            WoToast.show(withText:"通通分析中，请等待")
//            return
//        }
        onEvent?(.touchesBegan)
        isRecording = true
        showRecordingState()
        

        let authStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch authStatus {
        case .notDetermined:
            self.startRecording()
        case .restricted:break
//            WoToast.show(withText:"语音未授权，语音对话暂不可用")
        case .denied:break
//            WoToast.show(withText:"语音未授权，语音对话暂不可用")
        case .authorized:break
            self.startRecording()
        @unknown default: break
//            WoToast.show(withText:"语音未授权，语音对话暂不可用")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard mode == .voice, isRecording, let p = touches.first?.location(in: self) else { return }
        let inside = recordOverlay.frame.origin.y < p.y
        if inside, isInCancelZone {
            isInCancelZone = false
            showRecordingState()
        } else if !inside, !isInCancelZone {
            isInCancelZone = true
            showCancelState()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onEvent?(.touchesEnded)
        guard mode == .voice, isRecording else { return }
        isRecording = false
        recordOverlay.isHidden = true
        hintLabel.isHidden = false
        keyboardButton.isHidden = false
        let save = touches.first.map { recordOverlay.frame.contains($0.location(in: self)) } ?? false
        finishRecording(save: save)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onEvent?(.touchesCancelled)
        guard mode == .voice, isRecording else { return }
        isRecording = false
        hintLabel.isHidden = false
        keyboardButton.isHidden = false
        recordOverlay.isHidden = true
        finishRecording(save: false)
    }
    
    // MARK: - 录音状态显示
    
    private func showRecordingState() {
        onEvent?(.touchesInside)
        recordOverlay.isHidden = false
        recordOverlay.isSelected = false
        hintLabel.isHidden = true
        keyboardButton.isHidden = true
    }
    
    private func showCancelState() {
        onEvent?(.touchesOutside)
        recordOverlay.isHidden = false
        recordOverlay.isSelected = true
    }
    
    // MARK: - 录音流程
    private func startRecording() {

//        viewModel.stopPlay()
        
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
        let file = "audio.pcm"
        audioURL = URL(fileURLWithPath: NSTemporaryDirectory() + file)
        print("audioURL : \(String(describing: audioURL?.absoluteString))")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
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
        audioRecorder = nil
        if (save){
            voiceRecognitio()
        }else{
            audioURL = nil
        }
        
    }
    
    private func voiceRecognitio(){
        guard let url = audioURL ,let pcmData = try? Data(contentsOf: url) else {
            return
        }
        WTVASRTool.wtvReqVoice(with: pcmData) { success, message, error in
            print("语音转换 : \(success) -- message : \(message)")
            if success {
                self.sendMessage(message: message)
            }else{
//                WoToast.show(withText:"未识别到文字");
            }

        }
    }
    
}

// MARK: - UITextViewDelegate
extension TTCombinedInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if !textView.text.isEmpty {
//                if self.viewModel.isConnecting {
//                    WoToast.show(withText:"通通分析中，请等待")
                    textView.resignFirstResponder()
//                }else{
//                    onFinishRecording?(textView.text)
                    sendMessage(message: textView.text)
                    textView.text = ""
                    isSendReset = true

                    textDidChange()
//                }
            }
            return false
        }
        return true
    }
}
