import UIKit

/// 绘制中心对称的频谱条视图，固定尺寸为 240×200，并降低振幅波动范围
class SpectrumView: UIView {
    /// 固定视图尺寸
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 240, height: 200)
    }

    /// 外部不断赋新值的频谱振幅数组
    var magnitudes: [Float] = [] {
        didSet { setNeedsDisplay() }
    }

    /// 单根条的宽度
    private let barWidth: CGFloat = 4
    /// 条之间的间距
    private let barSpacing: CGFloat = 5
    /// 振幅到像素高度的缩放（原 200，现调低至 80）
    private let amplitudeScale: CGFloat = 80

    override func draw(_ rect: CGRect) {
        guard !magnitudes.isEmpty, let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)
        ctx.setFillColor(UIColor.white.cgColor)

        let centerY = rect.midY
        let centerX = rect.midX

        // 绘制左右对称的频谱条
        for (i, mag) in magnitudes.enumerated() {
            // 限制最大高度，防止超出视图边界
            let rawHeight = CGFloat(mag) * amplitudeScale
            let height = min(rawHeight, rect.height / 2)

            // 计算水平偏移
            let offset = CGFloat(i) * (barWidth + barSpacing) + barSpacing/2 + barWidth/2
            let xRight = centerX + offset - barWidth/2
            let xLeft  = centerX - offset - barWidth/2

            // 生成条形框
            let barRectRight = CGRect(x: xRight,
                                      y: centerY - height,
                                      width: barWidth,
                                      height: height * 2)
            let barRectLeft  = CGRect(x: xLeft,
                                      y: centerY - height,
                                      width: barWidth,
                                      height: height * 2)

            // 绘制条形
            ctx.fill(barRectRight)
            ctx.fill(barRectLeft)
        }
    }
}
