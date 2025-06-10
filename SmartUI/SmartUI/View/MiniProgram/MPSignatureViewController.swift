//
//  MPSignatureViewController.swift
//  SmartUI
//
//  Created by why on 2025/4/28.
//

import UIKit

import UIKit

class MPSignatureViewController: UIViewController {

    private let navBar = UIView()
    private let titleLabel = UILabel()
    private let drawView = SignatureDrawView()
    private let buttonStackView = UIStackView()
    private let bottomBar = UIView()
    
    var onComplete: ((UIImage?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // 顺序非常重要！
        view.addSubview(navBar)
        view.addSubview(bottomBar)
        view.addSubview(drawView)
        
        setupNavBar()
        setupBottomBar()
        setupDrawView()
        setupButtons()
    }

    
    func setupNavBar() {
        navBar.backgroundColor = .white
        navBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        let titleLabel = UILabel()
        titleLabel.text = "添加签名"
        titleLabel.textColor = UIColor(hexString: "#333333")
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        navBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }


    func setupDrawView() {
        drawView.backgroundColor = UIColor(hexString: "#F8F8F8")
        drawView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
    }

    
    func setupBottomBar() {
        bottomBar.backgroundColor = .white
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
    }


    func setupButtons() {
        let titles = ["关闭", "撤销", "重签", "确认"]
        let actions: [Selector] = [#selector(close), #selector(undo), #selector(clear), #selector(confirm)]

        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .equalSpacing
        buttonStackView.spacing = 20
        bottomBar.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            if title == "确认"{
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(hexString: "#E60027")
            }else{
                button.setTitleColor(UIColor(hexString: "#666666"), for: .normal)
                button.backgroundColor = UIColor(hexString: "#F8F8F8")
            }
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.addTarget(self, action: actions[index], for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalTo(80)
                make.height.equalTo(40)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: drawView)
            let path = UIBezierPath()
            path.lineWidth = 2
            path.move(to: point)
            drawView.lines.append(path)
            drawView.placeHolderHidden = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: drawView)
            drawView.lines.last?.addLine(to: point)
            drawView.setNeedsDisplay()
        }
    }

    @objc func close() {
        dismiss(animated: true) {
            self.forcePortrait()
        }
    }

    @objc func undo() {
        _ = drawView.lines.popLast()
        if drawView.lines.isEmpty {
            drawView.placeHolderHidden = false
        }
        drawView.setNeedsDisplay()
    }

    @objc func clear() {
        drawView.lines.removeAll()
        drawView.placeHolderHidden = false
        drawView.setNeedsDisplay()
    }

    @objc func confirm() {
        UIGraphicsBeginImageContextWithOptions(drawView.bounds.size, false, 0)
        drawView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let signatureImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        dismiss(animated: true) {
            self.forcePortrait()
            self.onComplete?(signatureImage)
        }
    }

    // MARK: 横屏设置

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return true
    }

    private func forcePortrait() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}
