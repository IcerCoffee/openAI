//
//  MPModel.swift
//  Gateway_2_0
//
//  Created by 吴敏轩 on 2025/3/31.
//  Copyright © 2025 Mile. All rights reserved.
//

import UIKit
import KakaJSON

class MPModel: NSObject, Convertible, Codable {
    var baseInfo: MPBaseInfo = MPBaseInfo()
    var companyInfo: MPCompanyInfo = MPCompanyInfo()
    var versionInfo: MPVersionInfo = MPVersionInfo()
    var safeDomains: [MPSafeDomain] = [MPSafeDomain]()
    var capacities: [MPCapacitie] = [MPCapacitie]()
    var extInfo: MPExtInfo = MPExtInfo()
    
    required override init(){
        super.init()
    }
}

class MPBaseInfo: NSObject, Convertible, Codable {
    var mpId: String = ""
    var name: String = ""
    var shortName: String = ""
    var mpDesc: String = ""
    var icon: String = ""
    var clientId: String = ""
    var collect: Bool = false
    required override init(){
        super.init()
    }
}

class MPCompanyInfo: NSObject, Convertible, Codable {
    var name: String = ""
    
    required override init(){
        super.init()
    }
}

class MPVersionInfo: NSObject, Convertible, Codable {
    var versionCode: String = ""
    var versionName: String = ""
    var versionDesc: String = ""
    var versionType: String = ""
    var packageMD5: String = ""
    var downloadUrl: String = ""
    
    required override init(){
        super.init()
    }
}

class MPSafeDomain: NSObject, Convertible, Codable {
    var domain: String = ""
    var type: String = ""
    
    required override init(){
        super.init()
    }
}

class MPCapacitie: NSObject, Convertible, Codable {
    var capCode: String = ""
    var capName: String = ""
    var capDesc: String = ""
    var requireAuth: String = ""
    // —— 新增 scope 列表 ——
    var scopes: [MPScope] = []
    
    required override init(){
        super.init()
    }
}


class MPExtInfo: NSObject, Convertible, Codable {
    var authPop: String = ""
    var loadOptimize: String = ""
    
    required override init(){
        super.init()
    }
}

// 新增：表示某个能力下需要申请的权限范围
class MPScope: NSObject, Convertible, Codable {
    var orderNum: Int = 0
    var scopeName: String = ""
    var scopeCode: String = ""
    var scopeDesc: String = ""
    required override init() { super.init() }
}

