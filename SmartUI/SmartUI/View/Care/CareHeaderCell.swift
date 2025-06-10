//
//  CareHeaderCell.swift
//  SmartUI
//
//  Created by why on 2024/10/31.
//

import UIKit

class CareHeaderCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame);
        initilizationUI()
    }
    
    private func initilizationUI(){
        let titleLabel = UILabel();
        titleLabel.text = "您好，WO_2003";
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
