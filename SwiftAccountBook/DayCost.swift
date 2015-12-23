//
//  DayCost.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/23.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class DayCost: NSManagedObject {
    
    @NSManaged var date: NSDate
    @NSManaged var records: [Record]
    
    var cost: Double {
        let sum = records.reduce(0.0) { sum, record in
            return sum + record.number
        }
        return sum
    }
}
