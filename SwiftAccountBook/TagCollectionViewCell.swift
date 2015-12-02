//
//  TagCollectionViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/1.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagNameLabel: UILabel!
    
    func configCell(tagName: String) {
        tagNameLabel.text = tagName
    }
}
