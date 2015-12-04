//
//  Constants.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/3.
//  Copyright © 2015年 王森. All rights reserved.
//

import Foundation

struct Constants {
    static let DocumentsDirectoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let TagArchiveURL = DocumentsDirectoryURL.URLByAppendingPathComponent("tags")
}

