//
//  VoiceSpectrumView.swift
//  SmartUI
//
//  Created by why on 2025/5/13.
//

import UIKit

class VoiceSpectrumView: UIView {
    private var barLayers: [CAShapeLayer] = []
    private let numberOfBars = 20
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBars()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBars()
    }

    private func setupBars() {
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            barLayer.backgroundColor = UIColor.white.cgColor
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            barLayer.frame = CGRect(x: xPosition, y: bounds.height, width: barWidth, height: 0)
            layer.addSublayer(barLayer)
            barLayers.append(barLayer)
        }
    }

    func update(with power: Float) {
        let normalizedPower = max(0, (power + 160) / 160)
        let maxHeight = bounds.height
        for barLayer in barLayers {
            let height = CGFloat(normalizedPower) * maxHeight * CGFloat.random(in: 0.5...1.0)
            barLayer.frame.origin.y = maxHeight - height
            barLayer.frame.size.height = height
        }
    }
}
