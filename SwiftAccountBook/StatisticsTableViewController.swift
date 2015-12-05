//
//  StatisticsTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/4.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {
    
    var recordsArray: [[Record]] = [[Record]]()
    var tagSumTuples: [(tag: String, sum: Double)] = [(tag: String, sum: Double)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let recordsArray = loadRecords() {
            self.recordsArray = recordsArray
        }
        
        // tuples with empty cost
        loadTags()?.forEach{ tag in tagSumTuples.append((tag, 0.0)) }
        // all records
        let allRecords = recordsArray.flatten()
        
        for (index, tuple) in tagSumTuples.enumerate() {
            tagSumTuples[index].sum = allRecords.filter { record in record.tags.contains(tuple.tag) }.reduce(0.0) { cost, record in cost + record.number }
        }
        tagSumTuples = tagSumTuples.filter { _, sum in sum > 0 }
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tagSumTuples.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
