//
//  RequstVC.swift
//  SmartUI
//
//  Created by why on 2024/10/15.
//

import UIKit

class RequstVC: UOTopBarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initilizationUI()
        pushTemplate()
        // Do any additional setup after loading the view.
    }
    

    private func initilizationUI(){
        self.title = "网络请求"
        view.backgroundColor = .white
        exchangeModel()
        userIdDecode()
    }
    
    private func userIdDecode(){
        let uid = "U2FsdGVkX1+7llxiePOGqK2yrg/isthIxjZG14Yi+7I=" as String
//        let phone = uid.mw_triple3DES(usingKey: "e1f6b864d72dd2315329b65f5b773130", option: 1);
//        let phone =  uid mwtr
//        print("解密 ： \(phone)")
    }
    
    private func exchangeModel(){
        let param = [
            "templateId": "GXXC_UPDATE_REMINDER", //固定值：GXXC_UPDATE_REMINDER
            "targetUsers": [
                "01O3k5rkQjuUp6wcEWQJsFsw==",  //接收方userid,对应华为侧userAccount
                "01O3k5rkQjuUp6wcEWQJsFsw=="
            ],
            "contentParams": [
                "01E83iT13cmWR6V/ZtcAx68w==",//推送模版占位参数1，上传者userAccount
                "测试家庭相册"  //推送模版占位参数2，上传图片的相册名称
            ],
            "extras": [
                "pageFlag": "NAS_PIC_HUAWEI" //跳转相册，固定值：NAS_PIC_HUAWEI
            ]
        ] as [String : Any]
    }
    
    private func pushTemplate(){
        
        let param = [
            "templateId":"GXXC_UPDATE_REMINDER",
            "pointKey":"abc",
            "pointValue":"123",
            "pointDesc":"desc",
            "contentParam":[["15104156258","测试家庭相册"],["15104156258","测试家庭相册"]],
            "params":["pageCode":"SpeedTestPage"],
            "customParam":[["pageCode":"speedTestPage"],["pageCode":"speedTestPage"]],
            "userId":["15524861813","15104156258"],
            "channel":"1001000001"
        ] as [String : Any]
        
        let userRequest = UserRequest(key: "PushTemplate", bodyDict: param)
        userRequest.requestSuccess { [weak self] dic in
            guard let self = self else {
                return
            }
//            self.queryUser(complete: complete)
        } fail: { dic in
//            UOHUD.hide()
        }
    }
    
    
    
    /*
     {
         "templateId": "GXXC_UPDATE_REMINDER", //固定值：GXXC_UPDATE_REMINDER
         "targetUsers": [
             "01O3k5rkQjuUp6wcEWQJsFsw==",  //接收方userid,对应华为侧userAccount
             "01O3k5rkQjuUp6wcEWQJsFsw=="
         ],
         "contentParams": [
             "01E83iT13cmWR6V/ZtcAx68w==",//推送模版占位参数1，上传者userAccount
             "测试家庭相册"  //推送模版占位参数2，上传图片的相册名称
         ],
         "extras": {
             "pageFlag": "NAS_PIC_HUAWEI" //跳转相册，固定值：NAS_PIC_HUAWEI
         }
     }
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
