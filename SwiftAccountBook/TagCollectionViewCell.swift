//
//  TagCollectionViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagNameLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        backgroundView = UIImageView(image: UIImage(named: "tag_background_normal"))
//        selectedBackgroundView = UIImageView(image: UIImage(named: "tag_background_selected"))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tagNameLabel.layer.borderWidth = 1
        self.tagNameLabel.layer.borderColor = ThemeManager.currentTheme.mainColor.CGColor
        self.tagNameLabel.layer.cornerRadius = 8
        self.tagNameLabel.clipsToBounds = true
    }
}
