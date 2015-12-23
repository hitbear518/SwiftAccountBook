//
//  Record.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/18.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class Record: NSManagedObject {
    
    @NSManaged var number: Double
    @NSManaged var date: NSDate
    @NSManaged var tags: [Tag]?
    
    var dayInEra: Int {
        let calendar = NSCalendar.currentCalendar()
        let day = calendar.ordinalityOfUnit(.Day, inUnit: .Era, forDate: date)
        return day
    }
    
}
