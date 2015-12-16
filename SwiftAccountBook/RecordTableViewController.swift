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
    
    var dateRecordsSumExpandedTuples = [(date: NSDate, records: [Record], sum: Double, expanded: Bool)]()
    let calendar = NSCalendar.init(identifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dateRecordsSumExpandedTuples.removeAll()
        loadRecords()?.enumerate().forEach { index, records in
            dateRecordsSumExpandedTuples.append((records[0].date, records, 0.0, false))
            updateSumForTuple(&dateRecordsSumExpandedTuples[index])
        }
        
        if !dateRecordsSumExpandedTuples.isEmpty {
            dateRecordsSumExpandedTuples[0].expanded = true
            tableView.reloadData()
        }
    }
    
    func updateSumForTuple(inout tuple: (date: NSDate, records: [Record], sum: Double, expanded: Bool)) {
        tuple.sum = tuple.records.reduce(0.0) { sum, record in sum + record.number }
    }
    
    func sumCostOf(records: [Record]) -> Double {
        return records.reduce(0.0) { cost, record in cost + record.number }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dateRecordsSumExpandedTuples.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateRecordsSumExpandedTuples[section].expanded {
            return dateRecordsSumExpandedTuples[section].records.count + 1
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DateSumCell", forIndexPath: indexPath)
            let (date, _, sum, _) = dateRecordsSumExpandedTuples[indexPath.section]
            if calendar.isDateInToday(date) {
                cell.textLabel?.text = "Today"
            } else if calendar.isDateInYesterday(date) {
                cell.textLabel?.text = "Yestoday"
            } else {
                cell.textLabel?.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: .LongStyle, timeStyle: .NoStyle)
            }
            cell .detailTextLabel?.text = String(sum)
            return cell
        } else {
           let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell
            let record = dateRecordsSumExpandedTuples[indexPath.section].records[indexPath.row - 1]
            cell.configCell(record)
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row > 0
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            dateRecordsSumExpandedTuples[indexPath.section].records.removeAtIndex(indexPath.row - 1)
            if (dateRecordsSumExpandedTuples[indexPath.section].records).isEmpty {
                dateRecordsSumExpandedTuples.removeAtIndex(indexPath.section)
                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                if !dateRecordsSumExpandedTuples.isEmpty {
                    setExpaned(true, atSection: 0)
                }
            } else {
                updateSumForTuple(&dateRecordsSumExpandedTuples[indexPath.section])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: indexPath.section)], withRowAnimation: .Fade)
            }
            tableView.endUpdates()
            
            saveRecords()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.beginUpdates()
            dateRecordsSumExpandedTuples.enumerate().filter({ $0.index != indexPath.section }).forEach {
                section, tuple in
                if (tuple.expanded) {
                    setExpaned(false, atSection: section) }
                }
            let expanded = !dateRecordsSumExpandedTuples[indexPath.section].expanded
            setExpaned(expanded, atSection: indexPath.section)
            tableView.endUpdates()
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
            
            let selectedTuple = dateRecordsSumExpandedTuples[selectedIndexPath.section]
            let selectedRecord = selectedTuple.records[selectedIndexPath.row - 1]
            
            recordViewController.record = Record(number: selectedRecord.number, tags: selectedRecord.tags, date: selectedRecord.date, recordDescription: selectedRecord.recordDescription)
        }
    }
    
    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        guard let sourceViewController = sender.sourceViewController as? RecordViewController, comingRecord = sourceViewController.record else { return }
        
        tableView.beginUpdates()
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Coming From record changing
            
            let selectedTuple = dateRecordsSumExpandedTuples[selectedIndexPath.section]
            let originalRecord = selectedTuple.records[selectedIndexPath.row - 1]
            if (originalRecord.date == comingRecord.date) {
                // Date didn't change
                
                dateRecordsSumExpandedTuples[selectedIndexPath.section].records[selectedIndexPath.row - 1] = comingRecord
                updateSumForTuple(&dateRecordsSumExpandedTuples[selectedIndexPath.section])
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .Fade)
            } else {
                // Date changed
                
                // Delete old record and insert new one
                dateRecordsSumExpandedTuples[selectedIndexPath.section].records.removeAtIndex(selectedIndexPath.row - 1)
                if dateRecordsSumExpandedTuples[selectedIndexPath.section].records.isEmpty {
                    // This day now has no records, delete the section
                    dateRecordsSumExpandedTuples.removeAtIndex(selectedIndexPath.section)
                    tableView.deleteSections(NSIndexSet(index: selectedIndexPath.section), withRowAnimation: .Fade)
                    if !dateRecordsSumExpandedTuples.isEmpty {
                        setExpaned(true, atSection: 0)
                    }
                } else {
                    updateSumForTuple(&dateRecordsSumExpandedTuples[selectedIndexPath.section])
                    tableView.deleteRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .Fade)
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: selectedIndexPath.section)], withRowAnimation: .Fade)
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
    
    func setExpaned(expanded: Bool, atSection section: Int) {
        guard dateRecordsSumExpandedTuples[section].expanded != expanded else { return }
        
        dateRecordsSumExpandedTuples[section].expanded = expanded
        
        let records = dateRecordsSumExpandedTuples[section].records
        var indexPaths = [NSIndexPath]()
        for row in 1...records.count {
            indexPaths.append(NSIndexPath(forRow: row, inSection: section))
        }
        if expanded {
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    func insertRecord(comingRecord: Record) {
        // If no data at all
        if dateRecordsSumExpandedTuples.isEmpty {
            dateRecordsSumExpandedTuples.append((comingRecord.date, [comingRecord], comingRecord.number, true))
            updateSumForTuple(&dateRecordsSumExpandedTuples[0])
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            return
        }
        
        let calendar = NSCalendar.currentCalendar()
        
        // Iterate table
        for (section, tuple) in dateRecordsSumExpandedTuples.enumerate() {
            if calendar.isDate(comingRecord.date, inSameDayAsDate: tuple.date) {
                // If find matching section
                dateRecordsSumExpandedTuples[section].records.insert(comingRecord, atIndex: 0)
                updateSumForTuple(&dateRecordsSumExpandedTuples[section])
                if (tuple.expanded) {
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: section)], withRowAnimation: .Fade)
                }
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: .Fade)
                return
            } else if comingRecord.date.timeIntervalSinceDate(tuple.date) > 0 {
                // Not matching section, but find older date
                dateRecordsSumExpandedTuples.insert((comingRecord.date, [comingRecord], comingRecord.number, false), atIndex: section)
                updateSumForTuple(&dateRecordsSumExpandedTuples[section])
                tableView.insertSections(NSIndexSet(index: section), withRowAnimation: .Fade)
                return
            }
            
        }
        
        // If no matching, then record date is oldest
        dateRecordsSumExpandedTuples.append((comingRecord.date, [comingRecord], comingRecord.number, false))
        updateSumForTuple(&dateRecordsSumExpandedTuples[dateRecordsSumExpandedTuples.count - 1])
        tableView.insertSections(NSIndexSet(index: dateRecordsSumExpandedTuples.count - 1), withRowAnimation: .None)
    }
    
   // MARK: - NSCoding
    
    func saveRecords() {
        let recordsArray = dateRecordsSumExpandedTuples.map { _, records, _, _  in records}
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(recordsArray, toFile: Record.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save records")
        }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
}
