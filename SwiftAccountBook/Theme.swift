//
//  Theme.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/12.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

let SelectedThemeKey = "SelectedTheme"

enum Theme: Int {
    case Default
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return Utils.colorFromRGBAHex(0xD25C58)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return Utils.colorFromRGBAHex(0xF1E9D3)
        }
    }
    
    var hightlightColor: UIColor {
        switch self {
        case .Default:
            return Utils.colorFromRGBAHex(0xF8F5EC)
        }
    }
}

struct ThemeManager {
    static var currentTheme: Theme {
       return Theme(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(SelectedThemeKey))!
    }
    
    static func applyTheme(theme: Theme) {
        UIApplication.sharedApplication().delegate?.window??.tintColor = theme.mainColor
        
        UITableView.appearance().backgroundColor = theme.backgroundColor
        UICollectionView.appearance().backgroundColor = theme.backgroundColor
        
    }
}
