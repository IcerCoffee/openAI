//
//  UBOTTErrorVC.swift
//  SmartUI
//
//  Created by why on 2024/12/24.
//

import UIKit

class UBOTTErrorVC: UOTopBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initilizationUI()
        // Do any additional setup after loading the view.
    }
    
    
    func initilizationUI(){
        self.title = "OTT账号选择"
        
        let bgView = UIScrollView()
        bgView.showsHorizontalScrollIndicator = false
        bgView.showsVerticalScrollIndicator = false
        bgView.contentSize = (CGSize(width: view.frame.width, height: view.frame.height))
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.backgroundColor = UIColor(hexString: "#F8F8F8")
        let tips = UIImageView(image: UIImage(named: "device_ottTips"))
        tips.contentMode = .scaleAspectFit
        bgView.addSubview(tips)
        tips.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.width.equalTo(197)
            make.left.equalTo(30)
            make.height.equalTo(35)
//            make.centerY.equalToSuperview()
        }
        
        let logoutTips = UIImageView(image: UIImage(named: "device_ottLogout"))
        bgView.addSubview(logoutTips)
        logoutTips.snp.makeConstraints { make in
            make.top.equalTo(tips.snp.bottom).offset(12)
            make.left.equalTo(15)
            make.width.equalTo(view.frame.width - 30)
            make.height.equalTo(logoutTips.snp.width)
        }
        
        let relogin = UIImageView(image: UIImage(named: "device_ottRelogin"))
        bgView.addSubview(relogin)
        relogin.snp.makeConstraints { make in
            make.left.right.equalTo(logoutTips)
            make.top.equalTo(logoutTips.snp.bottom).offset(20)
            make.height.equalTo(logoutTips.snp.width).multipliedBy(868/690.0)
            make.bottom.equalTo(bgView.snp.bottom).inset(45)
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
