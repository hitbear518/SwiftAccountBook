//
//  MyTabBarViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/23.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
        let firstNavController = viewControllers!.first as! UINavigationController
        let firstPageControllerWrapper = firstNavController.topViewController as! PageViewControllerWrapper
        firstPageControllerWrapper.isPayment = true
        
        let secondNavController = viewControllers![1] as! UINavigationController
        let secondPageControllerWrapper = secondNavController.topViewController as! PageViewControllerWrapper
        secondPageControllerWrapper.isPayment = false
    }
    
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        switch tabBar.selectedItem! {
        case tabBar.items![0]:
            ThemeManager.applyTheme(Theme.Payment)
        case tabBar.items![1]:
             ThemeManager.applyTheme(Theme.Income)
        default:
            ThemeManager.applyTheme(Theme.Default)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
