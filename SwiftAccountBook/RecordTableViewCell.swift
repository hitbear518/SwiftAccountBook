//
//  RecordTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/18.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var recordDescriptionLabel: UILabel!
    

    func configCell(record: Record) {
        tagLabel.text = record.tag ?? "Invalid Tag"
        numberLabel.text = String(record.number) ?? "Invalid Number"
        recordDescriptionLabel.text = record.recordDescription
    }
}
