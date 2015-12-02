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
    var tag: String
    var date: NSDate
    var recordDescription: String?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("records")
    
    // MARK: Property Keys
    
    struct PropertyKey {
        static let numberKey = "number"
        static let tagKey = "tag"
        static let dateKey = "date"
        static let recordDescriptionKey = "recordDescription"
    }
    
    
    init?(number: Double, tag: String, date: NSDate, recordDescription: String? = nil) {
        self.number = number
        self.tag = tag
        self.date = date
        self.recordDescription = recordDescription
        super.init()
        
        if number == 0.0 {
            return nil
        }
        
        if tag.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(number, forKey: PropertyKey.numberKey)
        aCoder.encodeObject(tag, forKey: PropertyKey.tagKey)
        aCoder.encodeObject(date, forKey: PropertyKey.dateKey)
        aCoder.encodeObject(recordDescription, forKey: PropertyKey.recordDescriptionKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeDoubleForKey(PropertyKey.numberKey)
        let tag = aDecoder.decodeObjectForKey(PropertyKey.tagKey) as! String
        let date = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        let recordDescription = aDecoder.decodeObjectForKey(PropertyKey.recordDescriptionKey) as? String
        self.init(number: number, tag: tag, date: date, recordDescription: recordDescription)
    }
}
