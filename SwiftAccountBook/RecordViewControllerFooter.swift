//
//  RecordVIewControllerFooter.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class RecordViewControllerFooter: UICollectionReusableView {
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var recordDescriptionTextView: UITextView!
    @IBOutlet weak var dateButton: UIButton!
    
    override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    
    
}
