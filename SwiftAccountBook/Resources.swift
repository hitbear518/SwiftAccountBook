//
//  Resources.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/20.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

struct Resources {
    
    static let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    
    static let DocumentsDirectoryURL = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
}