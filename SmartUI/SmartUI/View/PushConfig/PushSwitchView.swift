//
//  PushSwitchView.swift
//  SmartUI
//
//  Created by why on 2024/10/10.
//

import UIKit

class PushSwitchView: UIView {
    
    let titleLabel : UILabel = {
       let label = UILabel()
        label.text = "网络使用日报"
        label.textColor = .init(hexString: "#333333")
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let descLabel : UILabel = {
       let label = UILabel()
        label.text = "网络设备的网络日报消息"
        label.textColor = .init(hexString: "#999999")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let switchView : UISwitch = {
        let switchView = UISwitch()
        
        return switchView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilizationUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initilizationUI()
    }
    
    func initilizationUI() {
        
        self.layer.cornerRadius = 8
        self.backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(15)
        }
        
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        addSubview(switchView)
        switchView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
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
