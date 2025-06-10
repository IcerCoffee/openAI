//
//  CareViewController.swift
//  Gateway_2_0
//
//  Created by 朱鸿桥 on 2024/3/4.
//  Copyright © 2024 Mile. All rights reserved.
//

import UIKit
import AVFAudio

enum CareType: String {
    case scan     = "扫一扫"
    case device   = "设备列表"
    case landline = "智能固话"
    case speed    = "WiFi测速"
    case health   = "健康数据"
    
    var imageName: String {
        switch self {
        case .scan:
            return "care_scan"
        case .device:
            return "care_device"
        case .landline:
            return "care_landline"
        case .speed:
            return "care_speed"
        case .health:
            return "care_health"
        }
    }
}
//@objcMembers
class CareViewController: UOTopBarViewController {
    //AVSpeechSynthesizer *synthsizer
    let synthsizer = AVSpeechSynthesizer()
    var playIndex = NSIndexPath(row: 0, section: 0)
    var isPlaying : Bool = false {
        didSet{
            if isPlaying {
                if playIndex.row > 0{ //断点续播
                    playIndex = NSIndexPath(row: playIndex.row - 1, section: playIndex.section)
                }
                playNext()
            } else {
                synthsizer.stopSpeaking(at: .immediate)
            }
            updateButtonStatus()
        }
    }
    
    
    
    let action = UIButton(type: .custom)
    var customHeaderView: CareHeaderView? = nil
    static let screenW = UIScreen.main.bounds.width
    static let screenH = UIScreen.main.bounds.height
    static let topBarHeight = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.size.height
    static let kBottomSafeAreaHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    #if __IPHONE_11_0
    static let screenSafeArea = APP_Window!.safeAreaInsets
    #else
    static let screenSafeArea = UIEdgeInsets(top: (screenH >= 812 ? 44 : 20), left: 0, bottom: (screenH >= 812 ? 34 : 0), right: 0)
    #endif
    var navView = CareNavView()
    
    let dataArr: [CareType] = [.scan, .device, .landline, .speed, .health, .scan]

    lazy var careCollectView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        let width = floor((CareViewController.screenW-40)/2)
        let height = 128.0/375.0*CareViewController.screenW
        flowLayout.itemSize = CGSizeMake(width, height)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor(hexString: "#F8F8F8") //.hex(hex: "#F8F8F8")
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CareItemCell.self, forCellWithReuseIdentifier: "careCell")
        collectionView.register(CareHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "careHeader")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .init(hexString: "#F8F8F8")
        synthsizer.delegate = self
        initSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func exitAction() {
//        UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_Quit", label: "关爱版-退出")
//        CareforManager.shared.exitCareMode()
    }

    func initSubViews() {

        let statusBarHeight: CGFloat = {
            return UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
        }()

        let navigationBarHeight: CGFloat = 44.0
        let topToolBarHeight: CGFloat = navigationBarHeight + statusBarHeight
        self.navView.frame = CGRectMake(0, 0, CareViewController.screenW,  topToolBarHeight)   // =  CareNavView(frame: CGRectMake(0, 0, CareViewController.screenW,  topToolBarHeight))
        view.addSubview(self.navView)
        view.addSubview(careCollectView)
        print("bottom : \(String(describing: CareViewController.kBottomSafeAreaHeight))")
        careCollectView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(CareViewController.screenH - CareViewController.kBottomSafeAreaHeight - 54)
        }
        view.bringSubviewToFront(navView)
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.trailing.bottom.leading.equalToSuperview()
            make.height.equalTo(54+CareViewController.kBottomSafeAreaHeight)
        }
        
        
        action.setImage(UIImage(named: "care_sound"), for: .normal)
        action.setImage(UIImage(named: "care_sound"), for: .highlighted)
        action.setTitle("语音播报", for: .normal)
        action.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        action.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        // 调整内容的水平间距
        action.semanticContentAttribute = .forceLeftToRight // 确保图片在左，文字在右
        action.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0) // 调整图片与文字之间的间距
        action.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0) // 调整文字与图片之间的间距
        action.addTarget(self, action: #selector(playVoice), for: .touchUpInside)
        // 其他样式设置
        action.contentHorizontalAlignment = .left // 左对齐
        
        bottomView.addSubview(action)
        action.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
        }
        
    }
    
    
    
    @objc func playVoice() {
        isPlaying.toggle()
    }
    
    func playNext() {
        if (playIndex.section == 0){
            // 延迟 0.5 秒后开始播放语音
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                if isPlaying {
                    synthsizer.speak(getSpeechUtterance(text: customHeaderView?.playVoice(index: playIndex.row) ?? ""))
                }
            }
            
        }else{
            let careType = dataArr[playIndex.row]
            // 延迟 0.5 秒后开始播放语音
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[self] in
                if isPlaying{
                    synthsizer.speak(getSpeechUtterance(text: careType.rawValue))
                    careCollectView.reloadData()
                }
            }
        }
    }
    
    func updateButtonStatus() {
        if (isPlaying){
            action.setImage(UIImage(named: "care_sound_stop"), for: .normal)
            action.setImage(UIImage(named: "care_sound_stop"), for: .highlighted)
            action.setTitle("正在播报", for: .normal)
        }else{
            action.setImage(UIImage(named: "care_sound"), for: .normal)
            action.setImage(UIImage(named: "care_sound"), for: .highlighted)
            action.setTitle("语音播报", for: .normal)

        }
    }
    
    
    func getSpeechUtterance(text:String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.4
        return utterance
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension CareViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if (playIndex.section == 0){
            if (playIndex.row <= 2){
                playIndex = NSIndexPath(row: playIndex.row + 1, section: playIndex.section)
            }else{
                playIndex = NSIndexPath(row: 0, section: 1)
                customHeaderView?.resetUI()
            }
            playNext()
        } else {
            playIndex = NSIndexPath(row: playIndex.row + 1, section: playIndex.section)
            if (playIndex.row == dataArr.count){
                isPlaying = false
                playIndex = NSIndexPath(row: 0, section: 0) //重置播放位置
                careCollectView.reloadData()
            }else{
                playNext()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.navView .updateAppearance(offsetY: offset.y)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "careCell", for: indexPath) as! CareItemCell
        itemCell.setupData(careType: dataArr[indexPath.row])
        itemCell.isReading = indexPath.row == 2  //isPlaying && indexPath == playIndex as IndexPath
        return itemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (indexPath.section == 0){
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "careHeader", for: indexPath) as! CareHeaderView
        customHeaderView = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSizeZero
        }
        return CGSize(width: CareViewController.screenW, height: 258 + 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let careType = dataArr[indexPath.row]
        switch careType {
        case .scan:
//            UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_SYS", label: "关爱版-扫一扫")
//            WoHomeScanManager.shareInstance().scanQrcode()
            break
        case .device:
//            UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_SBLB", label: "关爱版-设备列表")
//            UINavigationController.pushVCName("CareDeviceListController")
            break
        case .landline:
//            UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_ZNGH", label: "关爱版-智能固话")
//            gotoLandline()
            break
        case .speed:
//            UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_WiFiCS", label: "关爱版-WiFi测速")
//            UOTestSpeedManager.getSpeedConfig()
            break
        case .health:
//            UAPPoint.default().startPointRecord(withPoint: "Caring_Edition_Home", describe: "Caring_Edition_JKSH", label: "关爱版-健康数据")
//            gotoHealth()
            break
        }
    }
    
//    func gotoLandline() {
//        let baseUrl = UOURLHelper.isTestEv() ? "https://test-iot.smartont.net" : "https://iotpservice.smartont.net"
//        let url = "\(baseUrl)/html/handheldhall/?clientId=1001000001&careType=1"
//        let config = UOWebViewHeaderConfig()
//        config.isNeedH5Header = true
//        config.h5Back = true
//        config.h5Close = false
//        config.h5Ext = false
//        let webView = UOWebViewController(url: url, title: "", config: config)
//        self.navigationController?.pushViewController(webView, animated: true)
//    }
    
//    func gotoHealth() {
//        let uidEncode = UserInfoManager.getUid().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        let urlStr = UOURLHelper.isTestEv() ? "https://www.gbkitten.com/" : "https://health.guangbao-uni.com/"
//        guard let currentHome = UOHomeManager.shared.currentHome else {
//            UOHomeManager.shared.getFamilyUserCurrent {
//                let url = String(format: "%@zhijia-biz/#/?userId=%@&homeId=%lu", urlStr, uidEncode, UOHomeManager.shared.currentHome.groupId)
//                UINavigationController.pushVCName("WCJsWebviewViewController", params: ["urlString":url, "indexNum":1])
//            }
//            return
//        }
//        let url = String(format: "%@zhijia-biz/#/?userId=%@&homeId=%lu", urlStr, uidEncode, currentHome.groupId)
//        UINavigationController.pushVCName("WCJsWebviewViewController", params: ["urlString":url, "indexNum":1])
//    }
}
