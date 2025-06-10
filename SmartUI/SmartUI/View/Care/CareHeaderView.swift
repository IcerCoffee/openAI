//
//  CareHeaderView.swift
//  SmartUI
//
//  Created by why on 2024/10/31.
//

import UIKit

class CareHeaderView: UICollectionReusableView {

    public let deviceList = CareItemCell()
    public let scan = CareItemCell()
    public let titleLable = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilizationUI()
    }
    
    // 播放内容需要给view添加Tag
    private func initilizationUI(){
        let bgview = UIImageView()
        self.addSubview(bgview);
        bgview.image = UIImage(named: "care_bg")
        bgview.snp.makeConstraints { make in
            make.edges.equalTo(self);
        };
        
        let bottomView = UIImageView()
        self.addSubview(bottomView)
        bottomView.image = UIImage(named: "care_bottom")
        bottomView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview();
            make.height.equalTo(16)
        }
        

        let width = floor((CareViewController.screenW-40)/2)
        let height = 104.0/375.0*CareViewController.screenW
    
        self.deviceList.titleLabel.text = "设备列表"
        self.deviceList.iconImageView.image = UIImage(named: "care_device")
        self.deviceList.showInHeader = true
        self.deviceList.tag = 2
        
        self.addSubview(self.deviceList)
        self.scan.titleLabel.text = "扫一扫"
        self.scan.iconImageView.image = UIImage(named: "care_scan")
        self.scan.showInHeader = true
        self.scan.tag = 3
        self.addSubview(self.scan)
        
        self.deviceList.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.size.equalTo(CGSizeMake(width, height))
            make.bottom.equalTo(bottomView.snp.top).offset(-10)
        }
        
        self.scan.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.size.equalTo(self.deviceList)
            make.centerY.equalTo(self.deviceList)
        }
        
        titleLable.text = "您好，WO_9832"
        titleLable.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLable.textColor = .white
        self.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.trailing.leading.equalTo(15)
            make.bottom.equalTo(deviceList.snp.top).offset(-10)
        }
        titleLable.tag = 1
    }
    
    func resetUI(){
        self.deviceList.isReading = false
        self.scan.isReading = false
    }
    
    func playVoice (index: Int) -> (String){
        
        switch index {
        case 1:
            return titleLable.text!
        case 2:
            self.deviceList.isReading = true
            return self.deviceList.titleLabel.text!
        case 3:
            self.deviceList.isReading = false
            self.scan.isReading = true
            return self.scan.titleLabel.text!
        default:
            return ""
        }
//            let view = viewWithTag(index)
//            guard (viewWithTag(index) != nil) else {
//                return ""
//            }
//            if let label = view as? UILabel{
//                return label.text ?? ""
//            } else if let button = view as? UIButton {
//                return button.titleLabel?.text ?? ""
//            } else if let careCell = view as? CareItemCell {
//
//                return careCell.titleLabel.text ?? ""
//            }
//            return ""
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
