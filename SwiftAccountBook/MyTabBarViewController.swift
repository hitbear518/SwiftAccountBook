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
    }
    
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            let rootViewController = navigationController.childViewControllers.first!
            if rootViewController is PaymentViewController {
                ThemeManager.applyTheme(Theme.Payment)
            } else if rootViewController is IncomeViewController {
                ThemeManager.applyTheme(Theme.Income)
            } else {
                ThemeManager.applyTheme(Theme.Default)
            }
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
