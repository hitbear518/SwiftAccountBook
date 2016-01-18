//
//  RecordView.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/5.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class RecordView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 6.0
        self.clipsToBounds = true
    }

}
