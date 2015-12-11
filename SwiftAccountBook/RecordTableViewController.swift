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
    var dateRecordsSumTuples = [(date: NSDate, records: [Record], sum: Double)]()
    var rows = [AnyObject]()
    let calendar = NSCalendar.init(identifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        loadRecords()?.enumerate().forEach { index, records in
            dateRecordsSumTuples.append((records[0].date, records, 0.0))
            updateSumForTuple(&dateRecordsSumTuples[index])
        }
    }
    
    func updateSumForTuple(inout tuple: (date: NSDate, records: [Record], sum: Double)) {
        tuple.sum = tuple.records.reduce(0.0) { sum, record in sum + record.number }
    }
    
    func sumCostOf(records: [Record]) -> Double {
        return records.reduce(0.0) { cost, record in cost + record.number }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateRecordsSumTuples.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (date, _, sum) = dateRecordsSumTuples[section]
        let dateString: String
        if calendar.isDateInYesterday(date) {
            dateString = "Yestoday"
        } else if calendar.isDateInToday(date) {
            dateString = "Today"
        } else {
            dateString = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        return "\(dateString) --- \(sum)"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateRecordsSumTuples[section].records.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell

        let record = dateRecordsSumTuples[indexPath.section].records[indexPath.row]
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
            dateRecordsSumTuples[indexPath.section].records.removeAtIndex(indexPath.row)
            if (dateRecordsSumTuples[indexPath.section].records).isEmpty {
                dateRecordsSumTuples.removeAtIndex(indexPath.section)
                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            } else {
                updateSumForTuple(&dateRecordsSumTuples[indexPath.section])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .None)
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
            
            let selectedTuple = dateRecordsSumTuples[selectedIndexPath.section]
            let selectedRecord = selectedTuple.records[selectedIndexPath.row]
            
            recordViewController.record = Record(number: selectedRecord.number, tags: selectedRecord.tags, date: selectedRecord.date, recordDescription: selectedRecord.recordDescription)
        }
    }
    
    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.sourceViewController as? RecordViewController, comingRecord = sourceViewController.record else { return }
        
        tableView.beginUpdates()
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Coming From record changing
            
            let selectedTuple = dateRecordsSumTuples[selectedIndexPath.section]
            let originalRecord = selectedTuple.records[selectedIndexPath.row]
            if (originalRecord.date == comingRecord.date) {
                // Date didn't change
                
                dateRecordsSumTuples[selectedIndexPath.section].records[selectedIndexPath.row] = comingRecord
                updateSumForTuple(&dateRecordsSumTuples[selectedIndexPath.section])
                tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Fade)
            } else {
                // Date changed
                
                // Delete old record and insert new one
                dateRecordsSumTuples[selectedIndexPath.section].records.removeAtIndex(selectedIndexPath.row)
                if dateRecordsSumTuples[selectedIndexPath.section].records.isEmpty {
                    // This day now has no records, delete the section
                    dateRecordsSumTuples.removeAtIndex(selectedIndexPath.section)
                    tableView.deleteSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Fade)
                } else {
                    updateSumForTuple(&dateRecordsSumTuples[selectedIndexPath.section])
                    tableView.reloadSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Fade)
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
        if dateRecordsSumTuples.isEmpty {
            dateRecordsSumTuples.append((comingRecord.date, [comingRecord], comingRecord.number))
            updateSumForTuple(&dateRecordsSumTuples[0])
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Right)
            return
        }
        
        let calendar = NSCalendar.currentCalendar()
        
        // Iterate table
        for (section, tuple) in dateRecordsSumTuples.enumerate() {
            if calendar.isDate(comingRecord.date, inSameDayAsDate: tuple.date) {
                // If find matching section
                dateRecordsSumTuples[section].records.insert(comingRecord, atIndex: 0)
                updateSumForTuple(&dateRecordsSumTuples[section])
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: .None)
                tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
                return
            } else if comingRecord.date.timeIntervalSinceDate(tuple.date) > 0 {
                // Not matching section, but find older date
                dateRecordsSumTuples.insert((comingRecord.date, [comingRecord], comingRecord.number), atIndex: section)
                updateSumForTuple(&dateRecordsSumTuples[section])
                tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .None)
                return
            }
            
        }
        
        // If no matching, then record date is oldest
        dateRecordsSumTuples.append((comingRecord.date, [comingRecord], comingRecord.number))
        updateSumForTuple(&dateRecordsSumTuples[dateRecordsSumTuples.count - 1])
        tableView.insertSections(NSIndexSet(index: dateRecordsSumTuples.count - 1), withRowAnimation: .None)
    }
    
   // MARK: - NSCoding
    
    func saveRecords() {
        let recordsArray = dateRecordsSumTuples.map { _, records, _  in records}
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(recordsArray, toFile: Record.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save records")
        }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
}
