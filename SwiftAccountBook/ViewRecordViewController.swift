//
//  ViewRecordViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/10.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class ViewRecordViewController: UIViewController {
    
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    }

    func showEditRecordViewController(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyBoard.instantiateViewControllerWithIdentifier("EditRecordViewController") as! EditRecordViewController
        vc.record = self.record
        showViewController(vc, sender: self)
    }

    @IBAction func deleteButtonDidTap(sender: AnyObject) {
        let belongedCollection = self.record.belongedCollection
        belongedCollection.records.remove(self.record)
        MyDataController.context.deleteObject(record)
        if belongedCollection.records.isEmpty {
            MyDataController.context.deleteObject(belongedCollection)
        }
        MyDataController.save()
        
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
