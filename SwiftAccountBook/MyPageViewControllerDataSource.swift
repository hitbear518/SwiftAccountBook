//
//  DayRecordCollectionDataSource.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/19.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class MyPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    var isPayment: Bool!
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? DayRecordTableViewController {
            let components = NSCalendar.currentCalendar().components([.Month], fromDate: viewController.startDate, toDate: NSDate(), options: [])
            if components.month >= 2 {
                return nil
            }
            
            let (startDate, endDate) = previousDates(viewController.startDate)
            let newViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("DayRecordTableViewController") as! DayRecordTableViewController
            newViewController.startDate = startDate
            newViewController.endDate = endDate
            newViewController.isPayment = self.isPayment
            return newViewController
        } else if let viewController = viewController as? TagRecordTableViewController {
            let components = NSCalendar.currentCalendar().components([.Month], fromDate: viewController.startDate, toDate: NSDate(), options: [])
            if components.month >= 2 {
                return nil
            }
            
            let (startDate, endDate) = previousDates(viewController.startDate)
            let newViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("TagRecordTableViewController") as! TagRecordTableViewController
            newViewController.startDate = startDate
            newViewController.endDate = endDate
            newViewController.isPayment = self.isPayment
            return newViewController
        }
        return nil
    }
    
    func monthsWithinYearFromDate(startDate: NSDate, toDate endDate: NSDate) -> Int {
        let startMonth = NSCalendar.currentCalendar().ordinalityOfUnit(.Month, inUnit: .Year, forDate: startDate)
        let endMonth = NSCalendar.currentCalendar().ordinalityOfUnit(.Month, inUnit: .Year, forDate: endDate)
        return endMonth - startMonth
    }
    
    func previousDates(lastStartDate: NSDate) -> (NSDate, NSDate) {
        let endDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: lastStartDate, options: [])!
        let startDate = NSCalendar.currentCalendar().nextDateAfterDate(endDate, matchingUnit: .Day, value: Settings.startDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits])!
        return (startDate, endDate)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? DayRecordTableViewController {
            if NSCalendar.currentCalendar().isDateInToday(viewController.endDate) {
                return nil
            }
            
            let (startDate, endDate) = nextDates(viewController.endDate)
            let newViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("DayRecordTableViewController") as! DayRecordTableViewController
            newViewController.startDate = startDate
            newViewController.endDate = endDate
            newViewController.isPayment = self.isPayment
            return newViewController
        } else if let viewController = viewController as? TagRecordTableViewController {
            if NSCalendar.currentCalendar().isDateInToday(viewController.endDate) {
                return nil
            }
            
            let (startDate, endDate) = nextDates(viewController.endDate)
            let newViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("TagRecordTableViewController") as! TagRecordTableViewController
            newViewController.startDate = startDate
            newViewController.endDate = endDate
            newViewController.isPayment = self.isPayment
            return newViewController
        }
        return nil
    }
    
    func nextDates(lastEndDate: NSDate) -> (NSDate, NSDate) {
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: lastEndDate, options: [])!
        var endDate: NSDate
        if isDateThisMonth(startDate) {
            endDate = NSDate()
        } else {
            endDate = NSCalendar.currentCalendar().nextDateAfterDate(startDate, matchingUnit: .Day, value: Settings.startDay, options: [.MatchPreviousTimePreservingSmallerUnits])!
            endDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: endDate, options: [])!
        }
        
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: endDate)
        let todayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: NSDate())
        if endDayInEra > todayInEra {
            endDate = NSDate()
        }
        
        return (startDate, endDate)
    }
    
    func isDateThisMonth(date: NSDate) -> Bool {
        var start: NSDate?
        var extends: NSTimeInterval = 0
        let success = NSCalendar.currentCalendar().rangeOfUnit(.Month, startDate: &start, interval: &extends, forDate: NSDate())
        if !success {
            return false
        }
        let startDateInSec = start!.timeIntervalSince1970
        let dateInSec = date.timeIntervalSince1970
        if dateInSec > startDateInSec && dateInSec < (startDateInSec + extends) {
            return true
        } else {
            return false
        }
    }
}
