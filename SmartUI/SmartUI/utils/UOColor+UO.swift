//
//  UOColor+UO.swift
//  Gateway_2_0
//
//  Created by zuo on 2021/6/1.
//  Copyright © 2021 Mile. All rights reserved.
//

import Foundation
extension UIColor {
    open class var selected: UIColor { UIColor.init(red: 255/255.0, green: 242/255.0, blue: 244/255.0, alpha: 1) }
    open class var theme: UIColor { UIColor.init(red: 230/255.0, green: 0/255.0, blue: 39/255.0, alpha: 1) }
    open class var bg: UIColor { UIColor.init(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1) }
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
         
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
         
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
         
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
         
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
         
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
