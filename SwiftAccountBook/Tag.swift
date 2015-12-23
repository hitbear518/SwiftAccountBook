//
//  Tag.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/23.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class Tag: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var records: [Record]?
    
    
}
