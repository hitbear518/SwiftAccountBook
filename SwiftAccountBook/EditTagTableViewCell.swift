//
//  EditTagTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/14.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class EditTagTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var recordTag: Tag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }
    
    func configCell(tag: Tag) {
        textField.text = tag.name
        label.text = String(tag.records.count)
        if tag.ofPayment {
            label.textColor = Theme.Payment.mainColor
        } else {
            label.textColor = Theme.Income.mainColor
        }
        self.recordTag = tag
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard !textField.text!.isEmpty else { return false }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.recordTag.name = textField.text!
        appDelegate.saveContext()
    }
}
