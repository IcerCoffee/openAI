//
//  PushConfigView.swift
//  SmartUI
//
//  Created by why on 2024/10/10.
//

import UIKit
import SnapKit

class PushConfigView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "开启联通智家消息通知，即时接收通知"
        label.textColor = .init(hexString: "#FF7030")
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    let settingButton : UIButton = {
        let button = UIButton()
        button.setTitle("去设置", for: .normal)
        button.setTitleColor(.init(hexString: "#E60027"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.addTarget(PushConfigView.self, action: #selector(openSetting), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilizationUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initilizationUI()
    }
    
    func initilizationUI(){
        self.backgroundColor = .init(hexString: "#FFF4E5")
        self.layer.cornerRadius = 8
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    @objc class func openSetting(){
        if let appSettingURL = URL(string: UIApplication.openSettingsURLString){
            if UIApplication.shared.canOpenURL(appSettingURL){
                UIApplication.shared.open(appSettingURL)
            }
        }
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
