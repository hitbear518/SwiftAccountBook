//
//  Tag+CoreDataProperties.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/24.
//  Copyright © 2015年 王森. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tag {
    @NSManaged var name: String
    @NSManaged var records: Set<Record>
}
