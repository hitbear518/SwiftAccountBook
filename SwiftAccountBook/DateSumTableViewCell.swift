//
//  DateSumTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/25.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class DateSumTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var expandedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
