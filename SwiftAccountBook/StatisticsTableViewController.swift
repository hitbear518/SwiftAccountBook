//
//  StatisticsTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/4.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var startingDate: NSDate!
    var endingDate: NSDate!
    var calendar = NSCalendar.currentCalendar()
    var startingDay: Int! {
        didSet {
            if oldValue != nil && oldValue != startingDay {
                startingDate = nil
                endingDate = now
            }
        }
    }
    var now: NSDate {
        return NSDate()
    }
    var recordsArray = [[Record]]()
    var tagSumTuples = [(tag: String, sum: Double)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nextImage = UIImage(named: "forward_button_image")
        nextButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, nextButton.frame.width - nextImage!.size.width, 0.0, 0.0)
        nextButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, nextImage!.size.width)
        
        endingDate = now
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        recordsArray.removeAll()
        if let recordsArray = loadRecords() {
            self.recordsArray = recordsArray
        }
        
        tagSumTuples.removeAll()
        // tuples with empty cost
        loadTags()?.forEach{ tag in tagSumTuples.append((tag, 0.0)) }
        // all records
        let allRecords = recordsArray.flatMap { $0 }
        
        for (index, tuple) in tagSumTuples.enumerate() {
            tagSumTuples[index].sum = allRecords.filter { record in record.tags.contains(tuple.tag) }.reduce(0.0) { cost, record in cost + record.number }
        }
        tagSumTuples = tagSumTuples.filter { _, sum in sum > 0 }
        tableView.reloadData()
        
        startingDay = NSUserDefaults.standardUserDefaults().integerForKey("StartingDay")
        updateDateInfo()
    }
    
    func updateDateInfo() {
        if startingDate == nil {
            if let match = calendar.nextDateAfterDate(endingDate, matchingUnit: .Day, value: startingDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits]) {
                startingDate = match
            } else {
                fatalError("find matching startingDate failed")
            }
        } else {
            if let match = calendar.nextDateAfterDate(startingDate, matchingUnit: .Day, value: startingDay, options: [.MatchPreviousTimePreservingSmallerUnits]) {
                endingDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: match, options: [])
                if isDateThisMonth(endingDate) {
                    endingDate = now
                }
            } else {
                fatalError("Find matching endingDate falied")
            }
        }
        
        
        let startingDateStr = NSDateFormatter.localizedStringFromDate(startingDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        var endingDateStr: String
        if calendar.isDate(endingDate, inSameDayAsDate: now) {
            endingDateStr = "Today"
            nextButton.enabled = false
        } else {
            endingDateStr = NSDateFormatter.localizedStringFromDate(endingDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
            nextButton.enabled = true
        }
        intervalLabel.text = "\(startingDateStr) - \(endingDateStr)"
    }
    
    func isDateThisMonth(date: NSDate) -> Bool {
        var start: NSDate?
        var extends: NSTimeInterval = 0
        let success = calendar.rangeOfUnit(.Month, startDate: &start, interval: &extends, forDate: NSDate())
        if !success { return false }
        let startDateInSec = start!.timeIntervalSince1970
        let dateInSec = date.timeIntervalSince1970
        if dateInSec > startDateInSec && dateInSec < (startDateInSec + extends) {

            return true
        } else {
            return false
        }
    }
    
    @IBAction func previousButtonDidTap(sender: AnyObject) {
        endingDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: startingDate, options: [])
        startingDate = nil
        updateDateInfo()
    }
    
    @IBAction func nextButtonDidTap(sender: AnyObject) {
        startingDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: endingDate, options: [])
        endingDate = nil
        updateDateInfo()
    }
    
    func sumCostOf(records: [Record]) -> Double {
        return records.reduce(0.0) { cost, record in cost + record.number }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
    
    func loadTags() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.TagArchiveURL.path!) as? [String]
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tagSumTuples.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatisticsTableViewCell", forIndexPath: indexPath) as! StatisticsTableViewCell
        
        // Configure the cell...
        let (tag, sum) = tagSumTuples[indexPath.row]
        cell.tagLabel.text = tag
        cell.sumLabel.text = String(sum)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
