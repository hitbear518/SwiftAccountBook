//
//  DatePickerViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/10.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.layer.cornerRadius = 12
        datePicker.layer.masksToBounds = true
        okButton.layer.cornerRadius = 12
        okButton.layer.masksToBounds = true
        
        NSUserDefaults.standardUserDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
