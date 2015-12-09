//
//  SettingsTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/8.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

protocol SettingsTableViewCellDelegate {
    func pickerViewDidSelect(day: Int)
}

class SettingsTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: SettingsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if let pickerView = pickerView {
            pickerView.delegate = self
            pickerView.dataSource = self
            
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }

    
    // MARK: UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerViewDidSelect(row + 1)
    }
}
