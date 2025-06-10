//
//  UOOTTAccountCell.swift
//  SmartUI
//
//  Created by why on 2024/12/12.
//

import UIKit

class UBOTTAccountCell: UITableViewCell {
    
    var accountLabel : UILabel!
    var descLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initilizationUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initilizationUI(){
        let bgView = UIView()
        self.backgroundColor = UIColor.clear
        bgView.backgroundColor = UIColor.white
        bgView.layer.cornerRadius = 12
        self.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalToSuperview().inset(15)
            make.top.equalTo(12)
            make.bottom.equalTo(-12)
        }
        
        
        self.accountLabel = UILabel();
        bgView.addSubview(self.accountLabel)
        self.accountLabel.snp.makeConstraints { make in
            make.left.top.equalTo(15)
            make.right.equalTo(12)
            make.bottom.equalToSuperview().inset(40)
        }
        
        
        self.descLabel = UILabel()
        bgView.addSubview(self.descLabel)
        self.descLabel.textColor = UIColor(hexString: "#A0A2A5")
        self.descLabel.font = UIFont.systemFont(ofSize:13)
        self.descLabel.snp.makeConstraints { make in
            make.right.left.equalTo(self.accountLabel)
            make.top.equalTo(self.accountLabel.snp.bottom).offset(8)
            
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
