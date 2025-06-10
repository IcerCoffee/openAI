//
//  CareNavView.swift
//  SmartUI
//
//  Created by why on 2024/10/31.
//

import UIKit

class CareNavView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilizationUI()
    }
    
    let bgView = UIImageView()
    
    lazy var titleLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.text = "关爱版"
        tLabel.font = .systemFont(ofSize: 25, weight: .medium)
        tLabel.textColor = .init(hexString: "#FFFFFF")
        return tLabel
    }()
    
    lazy var exitButton: UIButton = {
        let eButton = UIButton()
        eButton.setTitle("退出", for: .normal)
        eButton.setTitleColor(.init(hexString: "#FFFFFF"), for: .normal)
        eButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        eButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        return eButton
    }()
    
    @objc func exitAction() {
//        CareforManager.shared.exitCareMode()
    }

    
    public func updateAppearance(offsetY:CGFloat){
        if offsetY > 258 {
            self.backgroundColor = UIColor(hexString: "#F8F8F8")
            self.bgView.alpha = 1
        } else if offsetY <= 0 {
            self.bgView.alpha = 0
        } else {
            // 计算 alpha 从 0 到 1 的渐变
            let alpha = offsetY / 258.0
            self.bgView.alpha = alpha
            self.backgroundColor = UIColor.clear
        }
    }
    
    private func initilizationUI(){
        self.bgView.image = UIImage(named: "care_bg_nav")
        bgView.alpha = 0
        self.addSubview(self.bgView)
        self.bgView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        self.addSubview(titleLabel)
        self.addSubview(exitButton)
        let statusBarHeight: CGFloat = {
            return UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
        }()
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(statusBarHeight + 5)
            make.height.equalTo(35)
        }
        
        exitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
