//
//  CareItemCell.swift
//  SmartUI
//
//  Created by why on 2024/10/31.
//


import UIKit

class CareItemCell: UICollectionViewCell {
    
    private let coverView = UIView()

    public var _showInHeader = false
    var showInHeader:Bool{
        get {
            return _showInHeader
        }
        set(newVal){
            _showInHeader = newVal
            updateUI()
        }
    }
    
    
    public var _isReading = false
    var isReading :Bool {
        get {
            return _isReading
        }
        set(newVal){
            _isReading = newVal
            updateReadingUI(ret: newVal)
        }
    }
    
    
    lazy var iconImageView: UIImageView = {
        let iImageView = UIImageView()
        return iImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.font = .systemFont(ofSize: 20, weight: .regular)
        tLabel.textColor = UIColor(hexString: "#333333")
        return tLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        backgroundColor = .white
        layer.cornerRadius = 5
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        
        coverView.layer.borderColor = UIColor.white.cgColor
        coverView.layer.borderWidth = 1
        coverView.layer.cornerRadius = 8
        coverView.isHidden = true
        addSubview(coverView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        coverView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(68)
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
    
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(34)
        }
        
    }
    
    func setupData(careType: CareType) {
        iconImageView.image = UIImage(named: careType.imageName)
        titleLabel.text = careType.rawValue
    }
    
    
    func updateReadingUI(ret:Bool){
        coverView.isHidden = !self.isReading
        if self.showInHeader {
            coverView.layer.borderColor = UIColor(hexString: "#FFFFFF").cgColor
            layer.shadowColor = UIColor(hexString: "#E60027").cgColor
            backgroundColor = ret ? UIColor(white: 1, alpha: 0.1):UIColor.clear
        }else{
            if (ret){
                layer.shadowColor = UIColor(hexString: "#EE60027").cgColor
            }else{
                layer.shadowColor = UIColor(hexString: "#FFFFFF").cgColor
            }
            coverView.layer.borderColor = UIColor(hexString: "#EE60027").cgColor
            backgroundColor = .white
        }
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.25

    }
    
    func updateUI(){
        self.backgroundColor = UIColor.clear
        titleLabel.textColor = .white
        iconImageView.snp.updateConstraints { make in
            make.width.height.equalTo(42)
        }
    }
    
    

}
