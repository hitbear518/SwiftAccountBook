//
//  Record.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/18.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class Record: NSObject, NSCoding {
    
    // MARK: - Properties
    
    var number: Double
    var tags: [String]
    var date: NSDate
    var recordDescription: String?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("records")
    
    // MARK: Property Keys
    
    struct PropertyKey {
        static let numberKey = "number"
        static let tagsKey = "tags"
        static let dateKey = "date"
        static let recordDescriptionKey = "recordDescription"
    }
    
    
    init?(number: Double, tags: [String], date: NSDate, recordDescription: String? = nil) {
        self.number = number
        self.tags = tags
        self.date = date
        self.recordDescription = recordDescription
        super.init()
        
        if number == 0.0 {
            return nil
        }
        
        if tags.count == 0 {
            return nil
        }
        for tag in tags {
            if tag.isEmpty { return nil }
        }
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(number, forKey: PropertyKey.numberKey)
        aCoder.encodeObject(tags, forKey: PropertyKey.tagsKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(recordDescription, forKey: PropertyKey.recordDescriptionKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeDoubleForKey(PropertyKey.numberKey)
        let tags = aDecoder.decodeObjectForKey(PropertyKey.tagsKey) as! [String]
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        let recordDescription = aDecoder.decodeObjectForKey(PropertyKey.recordDescriptionKey) as? String
        self.init(number: number, tags: tags, date: date, recordDescription: recordDescription)
    }
}
