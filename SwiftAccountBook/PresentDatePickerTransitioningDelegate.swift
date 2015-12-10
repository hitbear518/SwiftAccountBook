//
//  PresentingDatePickerTransitioningDelegate.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/10.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class PresentDatePickerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PresentDatePickerPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    
}
