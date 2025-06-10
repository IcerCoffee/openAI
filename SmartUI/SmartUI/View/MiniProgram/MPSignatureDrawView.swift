//
//  MPSignatureDrawView.swift
//  SmartUI
//
//  Created by why on 2025/4/28.
//

import UIKit

class SignatureDrawView: UIView {

    var lines: [UIBezierPath] = []
    var placeHolderHidden: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        if !placeHolderHidden {
            // 画 placeHolder
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .medium),
                .foregroundColor: UIColor(hexString: "#EEEEEE"),
                .paragraphStyle: paragraph
            ]
            let text = "签名区"
            text.draw(in: CGRect(x: 0, y: (bounds.height - 40) / 2, width: bounds.width, height: 40), withAttributes: attrs)
        }

        UIColor.black.setStroke()
        for path in lines {
            path.stroke()
        }
    }
}
