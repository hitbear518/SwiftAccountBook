//
//  ViewRecordViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/10.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class ViewRecordViewController: UIViewController {
    
    @IBOutlet weak var paymentOrIncomeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var tagImageView: UIImageView!
    
    var record: Record!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: "showEditRecordViewController:")
        
        self.costLabel.text = String(self.record.number)
        self.tagsLabel.text = Utils.getTagsText(record.tags)
        self.datelabel.text = NSDateFormatter.localizedStringFromDate(record.date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        self.detailLabel.text = record.detail
        
        self.navigationItem.title = "浏览记录"
        if record.isPayment {
            self.paymentOrIncomeLabel.text = "支出："
            tagImageView.image = UIImage(named: "TagOpenedPayment")
            deleteButton.setBackgroundImage(UIImage(named: "ButtonBackgroundPayment"), forState: .Normal)
            deleteButton.setBackgroundImage(UIImage(named: "ButtonHighlightedBackgroundPayment"), forState: .Highlighted)
        } else {
            self.paymentOrIncomeLabel.text = "收入："
            tagImageView.image = UIImage(named: "TagOpenedIncome")
            deleteButton.setBackgroundImage(UIImage(named: "ButtonBackgroundIncome"), forState: .Normal)
            deleteButton.setBackgroundImage(UIImage(named: "ButtonHighlightedBackgroundIncome"), forState: .Highlighted)
        }
        
        
    }

    func showEditRecordViewController(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyBoard.instantiateViewControllerWithIdentifier("EditRecordViewController") as! EditRecordViewController
        vc.record = self.record
        vc.isPayment = record.isPayment
        
        showViewController(vc, sender: self)
    }

    @IBAction func deleteButtonDidTap(sender: AnyObject) {
        let belongedCollection = self.record.belongedCollection
        belongedCollection.records.remove(self.record)
        MyDataController.context.deleteObject(record)
        if belongedCollection.records.isEmpty {
            MyDataController.context.deleteObject(belongedCollection)
        }
        MyDataController.saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)
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
