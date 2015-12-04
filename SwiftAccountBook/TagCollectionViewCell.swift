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
        backgroundView = UIImageView(image: UIImage(named: "tag_bg_normal"))
        selectedBackgroundView = UIImageView(image: UIImage(named: "tag_bg_selected"))
    }
}
