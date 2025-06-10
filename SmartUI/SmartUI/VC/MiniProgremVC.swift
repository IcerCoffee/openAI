//
//  MiniProgremVC.swift
//  SmartUI
//
//  Created by why on 2025/4/14.
//
import Speech
import UIKit
typealias JSCallback = (String, Bool)->Void

class MiniProgremVC: UOTopBarViewController {
    let speechRecognizer = SpeechRecognizer()
    private let viewModel = TTAssistantViewModel()
    private let tipsView = TTVoiceRecorderTipsView()
    private let navCoverView = UIControl()
    private let coverView = UIControl()
    private lazy var combinedInputView : TTCombinedInputView = {
        let inputView = TTCombinedInputView(viewModel: viewModel)
        inputView.onEvent = { [weak self] event in
            guard let self = self else { return }
            self.tipsView.handle(event: event)
        }
        inputView.onTextInputStateChange = { state in
            print("“onTextInputStateChange“\(state)")
            if state == .fullscreen {
                self.navCoverView.isHidden = false
                self.coverView.isHidden = false
            }else{
                self.navCoverView.isHidden = true
                self.coverView.isHidden = true
            }
        }
        return inputView
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnabled = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnabled = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        requestSpeechAuthorization()
        setupVoiceInputView()
        // Do any additional setup after loading the view.
    }
    
    private func requestSpeechAuthorization() {
        speechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("语音识别已授权")
            case .denied, .restricted, .notDetermined:
                print("语音识别未授权")
            @unknown default:
                break
            }
        }
    }
    
    
    private func setupVoiceInputView() {
        
        self.navigationController?.navigationBar.addSubview(navCoverView)
        view.addSubview(coverView)
        view.addSubview(combinedInputView)
        view.addSubview(tipsView)

        navCoverView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        navCoverView.isHidden = true
        navCoverView.addTarget(self, action: #selector(navCoverTap), for: .touchUpInside)
        navCoverView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(UOConstants.navBarH)
            make.bottom.equalToSuperview()
        }
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        coverView.isHidden = true
        coverView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(UOConstants.screenH/4)
        }
        combinedInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(UOConstants.screenSafeArea.bottom)
            make.height.equalTo(80)
        }
        tipsView.snp.makeConstraints { make in
            make.bottom.equalTo(combinedInputView.snp.top).offset(-8)
            make.centerX.equalTo(combinedInputView)
            make.height.equalTo(90)
            make.width.equalToSuperview()
        }
        
    }
    

    
    @IBAction func settingTap(_ sender: Any) {
        let vc = MPSettingVC()
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    @IBAction func voiceTap(_ sender: Any) {
        let vc = SpectrumVC()
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    @IBAction func moreTapAction(_ sender: Any) {
        // 任意类型一行搞定
        PrivacyAccessStatisticsManager.shared.record(type: .location)      // 位置信息
        PrivacyAccessStatisticsManager.shared.record(type: .contacts)      // 通讯录
        PrivacyAccessStatisticsManager.shared.record(type: .systemVersion) // 其他类型，自动填充 -1

        print(PrivacyAccessStatisticsManager.shared.accessCount(for: .location))
        
        
        MPAbilityView.show(onItemTapped: { item in
            switch item {
            case .collect:
                print("点击了收藏")
            case .addToDekTop:
                print("点击了添加到桌面")
            case .reboot:
                print("点击了重新进入")
            }
        }, onHeaderTapped: {
            print("点击了 header 区域")
        })

    }
    
    @objc func navCoverTap(){
        view.endEditing(true)
    }
    
    @IBAction func tipTap(_ sender: Any) {
    
        let tips = MPTipsView(type: .authorization)
        tips.onConfirm = {
            print("用户点击确认授权")
        }
        tips.onCancel = {
            print("用户点击取消授权")
        }
        tips.show()


    }
    @IBAction func authTap(_ sender: Any) {
        MPAuthView.show(
            onReject: { print("用户点击拒绝") },
            onAllow: { print("用户点击允许") }
        )
    }


    @IBAction func infoTap(_ sender: Any) {
        self.navigationController?.pushViewController(MPInformationVC(), animated: true)
    }
    
    @IBAction func sign(_ sender: Any) {
        signature { result, ret in
            print(result)
        }
    }
    @IBAction func keyboardTap(_ sender: Any) {
        let vc = ChatViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 拉起签名页面
    func signature(completion: @escaping JSCallback) {
        DispatchQueue.main.async {
            let vc = MPSignatureViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.onComplete = { image in
                if let image = image,
                   let data = image.jpegData(compressionQuality: 0.8) {
                    let base64 = data.base64EncodedString()
                    if let jsonData = try? JSONSerialization.data(withJSONObject: ["data": base64], options: []),
                       let jsonStr = String(data: jsonData, encoding: .utf8) {
                        completion(jsonStr, true)
                    } else {
                        completion( "图片编码失败", false)
                    }
                } else {
                    completion("用户取消签名", false)
                }
            }
            
            if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                rootVC.present(vc, animated: true, completion: nil)
            } else {
                completion("无法找到顶层视图", false)
            }
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
