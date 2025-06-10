//
//  UBOTTNetworkErrorView.swift
//  SmartUI
//
//  Created by why on 2025/1/15.
//

import UIKit
import SnapKit

class UBOTTNetworkError: UIView {

    // Callback for retry action
    var onRetry: (() -> Void)?

    // UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "device_ottNetError")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "网络异常，请点击重试"
        label.textColor = UIColor(hexString: "#666666")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重试", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hexString: "#E60027")
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white

        // Add subviews
        addSubview(imageView)
        addSubview(messageLabel)
        addSubview(retryButton)

        // Add target to retry button
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        // Setup constraints using SnapKit
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
            make.width.height.equalTo(139)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        retryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(85)
            make.centerX.equalToSuperview()
            make.width.equalTo(210)
            make.height.equalTo(46)
        }
    }

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}

