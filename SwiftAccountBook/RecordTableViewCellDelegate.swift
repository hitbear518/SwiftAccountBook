//
//  RecordTableViewCellDelegate.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/26.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

protocol RecordTableViewCellDelegate {
    func sumViewDidTapAtCell(cell: UITableViewCell)
    func recordDidTap(record: Record)
}