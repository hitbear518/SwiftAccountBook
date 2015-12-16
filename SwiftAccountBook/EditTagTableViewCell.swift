//
//  EditTagTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/14.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

protocol EditTagTableViewCellDelegate {
    func tagDidEndEditing(before: String, after: String)
}

class EditTagTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var delegate: EditTagTableViewCellDelegate?
    var recordsArray = [[Record]]()
    var originalTag: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }
    
    func configCell(tuple: (tag: String, recordsCount: Int)) {
        textField.text = tuple.tag
        originalTag = tuple.tag
        label.text = String(tuple.recordsCount)
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
        if originalTag != textField.text! {
            delegate?.tagDidEndEditing(originalTag, after: textField.text!)
        }
    }
}
