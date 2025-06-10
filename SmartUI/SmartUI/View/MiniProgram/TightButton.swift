//
//  TightButton.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//

import UIKit

class TightButton: UIButton {

    /// 负值表示“往内”收缩多少点
       let touchMargin: CGFloat = -20

       override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
           // 把 bounds 向内缩 20pt，再检测是否包含触摸点
           let smallerBounds = bounds.insetBy(dx: -touchMargin, dy: -touchMargin)
           return smallerBounds.contains(point)
       }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
