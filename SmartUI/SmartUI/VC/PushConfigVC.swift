//
//  PushConfigVC.swift
//  SmartUI
//
//  Created by why on 2024/10/9.
//

import UIKit
import SnapKit
import UserNotifications

struct TipElement {
    let imageName: String
    let title: String
}

@objc class PushConfigVC: UOTopBarViewController {
    
    let pushConfigView = PushConfigView()
    
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initilizationUI()
        // Do any additional · after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        checkNotificationPermission { hasPermission in
            self.pushConfigView.isHidden = hasPermission
            self.pushConfigView.snp.makeConstraints { make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
                make.left.equalTo(self.titleLabel.snp.left)
                make.right.equalToSuperview().inset(15)
                make.height.equalTo(hasPermission ? 0:43)
            }
        }
    }
    
    func initilizationUI(){
        self.title = "消息设置"
        view.backgroundColor = .init(hexString: "#F8F8F8")
        
        titleLabel.text = "手机系统通知"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .init(hexString: "#333333")

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15);
            make.top.equalTo(10)
        }
        view.addSubview(pushConfigView)
        pushConfigView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(43)
        }
        
        let netLabel = UILabel()
        netLabel.text = "网络设备消息"
        netLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        netLabel.textColor = .init(hexString: "#999999")
        
        view.addSubview(netLabel)
        netLabel.snp.makeConstraints { make in
            make.left.equalTo(pushConfigView)
            make.right.equalToSuperview().inset(15);
            make.top.equalTo(pushConfigView.snp.bottom).offset(20)
        }
        
        let switchView = PushSwitchView()
        view.addSubview(switchView)
        switchView.snp.makeConstraints { make in
            make.left.equalTo(netLabel.snp.left)
            make.top.equalTo(netLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(62)
        }
        
        let tipsLabel = UILabel()
        tipsLabel.text = "手机系统通知形式示意"
        tipsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tipsLabel.textColor = .init(hexString: "#999999")

        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(switchView)
            make.right.equalToSuperview().inset(15);
            make.top.equalTo(switchView.snp.bottom).offset(20)
        }
        
        let elements = [
            TipElement(imageName: "pushConfig_lock", title: "锁定屏幕"),
            TipElement(imageName: "pushConfig_list", title: "通知中心"),
            TipElement(imageName: "pushConfig_banner", title: "横幅")
        ]
        
        let tipsView = UIStackView()
        tipsView.layer.cornerRadius = 8
        tipsView.backgroundColor = .white
        tipsView.axis = .horizontal
        tipsView.distribution = .fillEqually
        tipsView.alignment = .center
        tipsView.spacing = 15
        for element in elements {
            let elementView = createElementView(element: element)
            tipsView.addArrangedSubview(elementView)
        }
        
        view.addSubview(tipsView)
        tipsView.snp.makeConstraints { make in
            make.left.equalTo(tipsLabel)
            make.top.equalTo(tipsLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(125)
        }
        
    }
    
    func createElementView(element:TipElement) -> UIView{
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .center
        verticalStackView.spacing = 8
        
        let imageView = UIImageView(image: UIImage(named: element.imageName))
        imageView.snp.makeConstraints { make in
            make.width.equalTo(37)
            make.height.equalTo(75)
        }
        
        let label = UILabel()
        label.text = element.title
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        
        verticalStackView.addArrangedSubview(imageView)
        verticalStackView.addArrangedSubview(label)
        
        return verticalStackView
    }
    
    
    func checkNotificationPermission(completion: @escaping (Bool)-> Void){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.sync {
                switch settings.authorizationStatus {
                case .notDetermined:
                    completion(false)
                case .denied:
                    completion(false)
                case .authorized,.provisional:
                    completion(true)
                case .ephemeral:
                    completion(false)
                @unknown default:
                    completion(false)
                }
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
