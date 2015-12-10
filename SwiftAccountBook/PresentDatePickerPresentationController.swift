//
//  PresentingDatePickerPresentationController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/10.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class PresentDatePickerPresentationController: UIPresentationController {
    
    var dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        self.dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        dimmingView.alpha = 0.0
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dimmingViewTapped:"))
    }
    
    func dimmingViewTapped(sender: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let containerBounds = containerView!.bounds
        let presentedViewFrame = CGRectMake(10, containerBounds.height - 291, containerBounds.width - 20, 281)
       
        return presentedViewFrame
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0
        
        containerView?.insertSubview(dimmingView, atIndex: 0)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ context in
                self.dimmingView.alpha = 1.0
                }, completion: nil)
        } else {
            self.dimmingView.alpha = 1.0
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ context in
                self.dimmingView.alpha = 0.0

                }, completion: nil)
        } else {
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
