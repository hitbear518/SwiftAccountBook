//
//  IncomeViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/22.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class IncomeViewController: UIViewController {
    
    private lazy var dataSource: MyPageViewControllerDataSource = {
        let dataSource = MyPageViewControllerDataSource()
        dataSource.isPayment = self.isPayment
        return dataSource
    }()
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageVC.dataSource = self.dataSource
        return pageVC
    }()
    
    var originalStartDay = Settings.startDay
    var isPayment = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let startViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("DayRecordTableViewController") as! DayRecordTableViewController
        startViewController.endDate = NSDate()
        startViewController.isPayment = isPayment
        
        self.pageViewController.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if originalStartDay != Settings.startDay {
            originalStartDay = Settings.startDay
            
            if let _ = pageViewController.viewControllers?.first as? DayRecordTableViewController {
                let startViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("TagRecordTableViewController") as! TagRecordTableViewController
                startViewController.endDate = NSDate()
                startViewController.isPayment = isPayment
                pageViewController.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
                navigationItem.leftBarButtonItem?.image = UIImage(named: "BarButtonCalendar")
            } else if let _ = pageViewController.viewControllers?.first as? TagRecordTableViewController {
                let startViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("DayRecordTableViewController") as! DayRecordTableViewController
                startViewController.endDate = NSDate()
                startViewController.isPayment = isPayment
                pageViewController.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
                navigationItem.leftBarButtonItem?.image = UIImage(named: "BarButtonTag")
            } else {
                fatalError()
            }
        }
    }
    
    @IBAction func switchViewControllerType(sender: AnyObject) {
        if let currentVC = pageViewController.viewControllers?.first as? DayRecordTableViewController {
            let startViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("TagRecordTableViewController") as! TagRecordTableViewController
            startViewController.startDate = currentVC.startDate
            startViewController.endDate = currentVC.endDate
            startViewController.isPayment = isPayment
            pageViewController.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
            navigationItem.leftBarButtonItem?.image = UIImage(named: "BarButtonCalendar")
        } else if let currentVC = pageViewController.viewControllers?.first as? TagRecordTableViewController {
            let startViewController = Resources.mainStoryBoard.instantiateViewControllerWithIdentifier("DayRecordTableViewController") as! DayRecordTableViewController
            startViewController.startDate = currentVC.startDate
            startViewController.endDate = currentVC.endDate
            startViewController.isPayment = isPayment
            pageViewController.setViewControllers([startViewController], direction: .Forward, animated: false, completion: nil)
            navigationItem.leftBarButtonItem?.image = UIImage(named: "BarButtonTag")
        } else {
            fatalError()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "AddRecord" {
            let viewController = segue.destinationViewController.childViewControllers.first as! EditRecordViewController
            viewController.isPayment = isPayment
        }
    }
}
