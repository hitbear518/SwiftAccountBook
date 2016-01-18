//
//  DayCost+CoreDataProperties.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DayRecordCollection {

    @NSManaged var date: NSDate
    @NSManaged var dayInEra: Int
    @NSManaged var records: Set<Record>

}
