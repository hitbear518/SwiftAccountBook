//
//  Utils.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit
import CoreData

struct Utils {
    static func getTrancatedTagsText(tags: Set<Tag>?) -> String {
        guard let tags = tags else { return "无标签"}
        guard !tags.isEmpty else { return "无标签"}
        
        let sortedTagNames = tags.map({ $0.name })
        let prefix = sortedTagNames.prefix(2)
        var tagsText = prefix.joinWithSeparator(", ")
        if sortedTagNames.count > prefix.count {
            tagsText += ", (\(sortedTagNames.count - 2))"
        }
        return tagsText
    }
    
    static func getTagsText(tags: Set<Tag>?) -> String {
        guard let tags = tags else { return "无标签"}
        guard !tags.isEmpty else { return "无标签"}
        
        return tags.map({ $0.name }).joinWithSeparator(", ")
    }
    
    static func colorFromRGBAHex(var hex: Int) -> UIColor {
        let r, g, b, a: CGFloat
        if hex > 0xFFFFFF {
            
            a = CGFloat(hex & 0x000000FF)
            hex >>= 8
        } else {
            a = 255.0
        }
        
        r = CGFloat((hex & 0xFF0000) >> 16)
        g = CGFloat((hex & 0x00FF00) >> 8)
        b = CGFloat(hex & 0x0000FF)
        
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 255.0)
    }
    
    static func getDateStr(date: NSDate, dateStyle: NSDateFormatterStyle) -> String {
        if NSCalendar.currentCalendar().isDateInToday(date) {
            return "今天"
        } else if NSCalendar.currentCalendar().isDateInYesterday(date) {
            return "昨天"
        } else {
            return NSDateFormatter.localizedStringFromDate(date, dateStyle: dateStyle, timeStyle: .NoStyle)
        }
    }
}
