//
//  Settings.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/19.
//  Copyright © 2016年 王森. All rights reserved.
//

import Foundation


struct Settings {
    static let startDayKey = "StartDay"
    
    static var startDay: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(startDayKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: startDayKey)
        }
    }
}