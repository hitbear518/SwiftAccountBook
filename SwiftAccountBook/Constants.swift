//
//  Constants.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/3.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

struct Constants {
    static let DocumentsDirectoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let TagArchiveURL = DocumentsDirectoryURL.URLByAppendingPathComponent("tags")
    
    static let defaultRedColor = Utils.colorFromRGBAHex(0xD25C58)
    static let defaultBackgroundColor = Utils.colorFromRGBAHex(0xF1E9D3)
    static let defaultHighlightColor = Utils.colorFromRGBAHex(0xF8F5EC)
}

