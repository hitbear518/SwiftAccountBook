//
//  DatePickerTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/12.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

protocol PickerViewTableViewCellDelegate {
    func pickerViewDidSelect(day: Int)
}

class PickerViewTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    var delegate: PickerViewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let startingDay = NSUserDefaults.standardUserDefaults().integerForKey("StartingDay")
        pickerView.selectRow(startingDay - 1, inComponent: 0, animated: true)
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
