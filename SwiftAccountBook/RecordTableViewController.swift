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
    var dateRecordsTuples = [(date: NSDate, records: [Record])]()
    let calendar = NSCalendar.init(identifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        loadRecords()?.enumerate().forEach { index, records in
            dateRecordsTuples.append((records[0].date, records))
        }
    }
    
    func sumCostOf(records: [Record]) -> Double {
        return records.reduce(0.0) { cost, record in cost + record.number }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateRecordsTuples.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (date, records) = dateRecordsTuples[section]
        let dateString: String
        if calendar.isDateInYesterday(date) {
            dateString = "Yestoday"
        } else if calendar.isDateInToday(date) {
            dateString = "Today"
        } else {
            dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        let dayCost = sumCostOf(records)
        return "\(dateString) --- \(dayCost)"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateRecordsTuples[section].records.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell

        let record = dateRecordsTuples[indexPath.section].records[indexPath.row]
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
            dateRecordsTuples[indexPath.section].records.removeAtIndex(indexPath.row)
            if (dateRecordsTuples[indexPath.section].records).isEmpty {
                dateRecordsTuples.removeAtIndex(indexPath.section)
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
            let recordViewController = segue.destinationViewController as! RecordViewController2
            let selectedRecordCell = sender as! RecordTableViewCell
            let selectedIndexPath = tableView.indexPathForCell(selectedRecordCell)!
            
            let selectedTuple = dateRecordsTuples[selectedIndexPath.section]
            let selectedRecord = selectedTuple.records[selectedIndexPath.row]
            
            recordViewController.record = Record(number: selectedRecord.number, tags: selectedRecord.tags, date: selectedRecord.date, recordDescription: selectedRecord.recordDescription)
        }
    }
    
    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.sourceViewController as? RecordViewController2, comingRecord = sourceViewController.record else { return }
        
        tableView.beginUpdates()
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Coming From record changing
            
            let selectedTuple = dateRecordsTuples[selectedIndexPath.section]
            let originalRecord = selectedTuple.records[selectedIndexPath.row]
            if (originalRecord.date == comingRecord.date) {
                // Date didn't change
                
                dateRecordsTuples[selectedIndexPath.section].records[selectedIndexPath.row] = comingRecord
                tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .None)
            } else {
                // Date changed
                
                // Delete old record and insert new one
                dateRecordsTuples[selectedIndexPath.section].records.removeAtIndex(selectedIndexPath.row)
                if dateRecordsTuples[selectedIndexPath.section].records.isEmpty {
                    // This day now has no records, delete the section
                    dateRecordsTuples.removeAtIndex(selectedIndexPath.section)
                    tableView.deleteSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .None)
                } else {
                    // TODO: Check this path
                    tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Left)
                }
                insertRecord(comingRecord)
            }
        } else {
            // Coming From new record
            insertRecord(comingRecord)
        }
        tableView.endUpdates()
        
        saveRecords()
    }
    
    func insertRecord(comingRecord: Record) {
        // If no data at all
        if dateRecordsTuples.isEmpty {
            dateRecordsTuples.append((comingRecord.date, [comingRecord]))
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Right)
            return
        }
        
        let calendar = NSCalendar.currentCalendar()
        
        // If record date is newest
        let firstDate = dateRecordsTuples.map { $0.date }.first!
        if comingRecord.date.timeIntervalSinceDate(firstDate) > 0 {
            dateRecordsTuples.insert((comingRecord.date, [comingRecord]), atIndex: 0)
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .None)
            return
        }
        
        // Iterate table
        for (section, tuple) in dateRecordsTuples.enumerate() {
            if calendar.isDate(comingRecord.date, inSameDayAsDate: tuple.date) {
                // If find matching section
                dateRecordsTuples[section].records.insert(comingRecord, atIndex: 0)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: .None)
                return
            } else if comingRecord.date.timeIntervalSinceDate(tuple.date) > 0 {
                // If find older date
                dateRecordsTuples.insert((comingRecord.date, [comingRecord]), atIndex: section)
                tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .None)
                return
            }
            
        }
        
        // If no matching, then record date is oldest
        dateRecordsTuples.append((comingRecord.date, [comingRecord]))
        tableView.insertSections(NSIndexSet(index: dateRecordsTuples.count - 1), withRowAnimation: .None)
    }
    
   // MARK: - NSCoding
    
    func saveRecords() {
        let recordsArray = dateRecordsTuples.map { _, records -> [Record] in records }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(recordsArray, toFile: Record.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save records")
        }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
}
