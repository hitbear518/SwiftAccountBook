//
//  RecordVIewControllerFooter.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class EditRecordViewControllerFooter: UICollectionReusableView {
    
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var dateButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateButton.setTitle(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .FullStyle, timeStyle: .NoStyle), forState: .Normal)
        dateButton.layer.cornerRadius = 5
        dateButton.clipsToBounds = true
    }
}
