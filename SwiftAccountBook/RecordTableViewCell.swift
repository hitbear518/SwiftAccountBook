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
    
    func configCell(record: Record) {
        var tagsText = ""
        record.tags?.forEach {
            tagsText += "\($0.name), "
        }
        if !tagsText.isEmpty {
            tagsText = tagsText.substringWithRange(tagsText.startIndex..<tagsText.endIndex.advancedBy(-2))
        } else {
            tagsText = "No Tag"
        }
        
        textLabel?.text = tagsText
        detailTextLabel?.text = String(record.number)
    }
}
