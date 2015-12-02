//
//  RecordTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/18.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class RecordTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var recordsArray = [[Record]]()
    let calendar = NSCalendar.init(identifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let recordsArray = loadRecords() {
            self.recordsArray = recordsArray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return recordsArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = recordsArray[section][0].date
        let dateString: String
        if calendar.isDateInYesterday(date) {
            dateString = "Yestoday"
        } else if calendar.isDateInToday(date) {
            dateString = "Today"
        } else {
            dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        var dayCost = 0.0
        for record in recordsArray[section] {
            dayCost += record.number
        }
        return "\(dateString) --- \(dayCost)"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsArray[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell

        let record = recordsArray[indexPath.section][indexPath.row]
        cell.configCell(record)
    
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            recordsArray[indexPath.section].removeAtIndex(indexPath.row)
            if (recordsArray[indexPath.section]).isEmpty {
                recordsArray.removeAtIndex(indexPath.section)
                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            } else {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            saveRecords()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let recordViewController = segue.destinationViewController as! RecordViewController
            let selectedRecordCell = sender as! RecordTableViewCell
            let selectedIndexPath = tableView.indexPathForCell(selectedRecordCell)!
            let selectedRecord = recordsArray[selectedIndexPath.section][selectedIndexPath.row]
            recordViewController.record = Record(number: selectedRecord.number, tag: selectedRecord.tag, date: selectedRecord.date, recordDescription: selectedRecord.recordDescription)
        }
    }

    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.sourceViewController as? RecordViewController, record = sourceViewController.record else { return }
        
        tableView.beginUpdates()
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let originalRecord = recordsArray[selectedIndexPath.section][selectedIndexPath.row]
            if (originalRecord.date == record.date) {
                recordsArray[selectedIndexPath.section][selectedIndexPath.row] = sourceViewController.record!
                tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .None)
                
                
            } else {
                recordsArray[selectedIndexPath.section].removeAtIndex(selectedIndexPath.row)
                if recordsArray[selectedIndexPath.section].isEmpty {
                    recordsArray.removeAtIndex(selectedIndexPath.section)
                }
                tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Left)
                
                insertRecord(record)
            }
        } else {
            insertRecord(record)
        }
        tableView.endUpdates()
        
        saveRecords()
    }
    
    func insertRecord(record: Record) {
            if recordsArray.isEmpty {
                recordsArray.append([Record]())
                recordsArray[0].append(record)
                tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Right)
                return
            }
            
            let calendar = NSCalendar.currentCalendar()
            for i in 0..<recordsArray.count {
                if calendar.isDate(record.date, inSameDayAsDate: recordsArray[i][0].date) {
                    recordsArray[i].insert(record, atIndex: 0)
                    let newIndexPath = NSIndexPath(forRow: 0, inSection: i)
                    tableView.reloadSections(NSIndexSet(index: newIndexPath.section), withRowAnimation: .None)
                    break
                } else if record.date.timeIntervalSinceDate(recordsArray[i][0].date) > 0 {
                    recordsArray.insert([Record](), atIndex: i)
                    recordsArray[i].append(record)
                    tableView.insertSections(NSIndexSet(index: i), withRowAnimation: .Right)
                    break
                } else if i == recordsArray.count - 1 {
                    recordsArray.append([Record]())
                    recordsArray[i + 1].append(record)
                    tableView.insertSections(NSIndexSet(index: i + 1), withRowAnimation: .Right)
                }
            }
    }
    
   // MARK: - NSCoding
    
    func saveRecords() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(recordsArray, toFile: Record.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save records")
        }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
}
