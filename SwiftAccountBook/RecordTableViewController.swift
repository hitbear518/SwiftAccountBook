//
//  RecordTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/18.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class RecordTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, RecordSectionHeaderDelegate {
    
    // MARK: Properties
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    var dateRecordsSumExpandedTuples = [(date: NSDate, records: [Record], sum: Double, expanded: Bool)]()
    let calendar = NSCalendar.init(identifier: NSCalendarIdentifierGregorian)!
    var sectionOpened: Int?
    
    var fetchedResultsController: NSFetchedResultsController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.tableView.registerNib(UINib(nibName: "RecordSectionHeader", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "RecordSectionHeader")
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let recordRequest = NSFetchRequest(entityName: "Record")
        let dayInEraSortDescriptor = NSSortDescriptor(key: "dayInEra", ascending: false)
        
        recordRequest.sortDescriptors = [dayInEraSortDescriptor]
        var lastMonthFirstDay = NSDate()
        let day = calendar.ordinalityOfUnit(.Day, inUnit: .Month, forDate: lastMonthFirstDay)
        if day > 1 {
            lastMonthFirstDay = calendar.nextDateAfterDate(NSDate(), matchingUnit: .Day, value: 1, options: [.SearchBackwards, .MatchNextTime])!
        }
        lastMonthFirstDay = calendar.dateByAddingUnit(.Month, value: -1, toDate: lastMonthFirstDay, options: [])!
        recordRequest.predicate = NSPredicate(format: "date >= %@", lastMonthFirstDay)
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: recordRequest, managedObjectContext: self.moc, sectionNameKeyPath: "dayInEra", cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetched day costs: \(error)")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionOpened = self.sectionOpened where sectionOpened == section {
            return fetchedResultsController.sections![section].numberOfObjects
        } else  {
            return 0
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dayRecords = self.fetchedResultsController.sections![section].objects as! [Record]
        let date = dayRecords[0].date
        let dayCost = dayRecords.reduce(0.0) { sum, record in
            sum + record.number
        }
        let header = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("RecordSectionHeader") as! RecordSectionHeader
        if calendar.isDateInToday(date) {
            header.dateLabel?.text = "Today"
        } else if calendar.isDateInYesterday(date) {
            header.dateLabel?.text = "Yestoday"
        } else {
            header.dateLabel?.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: .FullStyle, timeStyle: .NoStyle)
        }
        header.sumLabel?.text = String(dayCost)
        
        header.delegate = self
        header.section = section
        return header
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell", forIndexPath: indexPath) as! RecordTableViewCell
        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! Record
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
            let recordToDelete = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Record
            moc.deleteObject(recordToDelete)
            
            appDelegate.saveContext()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            if let sectionOpened = self.sectionOpened where sectionOpened >= sectionIndex {
                self.sectionOpened! += 1
            }
            for section in sectionIndex..<self.tableView.numberOfSections {
                let header = self.tableView.headerViewForSection(section) as! RecordSectionHeader
                header.section = header.section + 1
            }
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            if let sectionOpened = self.sectionOpened where sectionOpened == sectionIndex {
                self.sectionOpened = nil
            }
            for section in (sectionIndex + 1)..<self.tableView.numberOfSections {
                let header = self.tableView.headerViewForSection(section) as! RecordSectionHeader
                header.section = header.section - 1
            }
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if self.sectionOpened == newIndexPath!.section {
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
            if self.tableView.numberOfSections == self.fetchedResultsController.sections!.count {
                updateSumAtSection(newIndexPath!.section)
            }
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            if self.tableView.numberOfRowsInSection(indexPath!.section) > 1 {
                updateSumAtSection(indexPath!.section)
            }
        case .Update:
            if self.sectionOpened == indexPath!.section {
                self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
            updateSumAtSection(indexPath!.section)
        case .Move:
            if self.tableView.numberOfSections < self.fetchedResultsController.sections!.count {
                if newIndexPath!.section <= indexPath!.section {
                    // section inserted and is before old section
                    let header = self.tableView.headerViewForSection(indexPath!.section) as! RecordSectionHeader
                    let sum = getSumAtSection(indexPath!.section + 1)
                    header.sumLabel?.text = String(sum)
                } else {
                    updateSumAtSection(indexPath!.section)
                }
            } else if self.tableView.numberOfSections > self.fetchedResultsController.sections!.count {
                if indexPath!.section <= newIndexPath!.section {
                    let header = self.tableView.headerViewForSection(newIndexPath!.section + 1) as! RecordSectionHeader
                    let sum = getSumAtSection(newIndexPath!.section)
                    header.sumLabel?.text = String(sum)
                } else {
                    updateSumAtSection(newIndexPath!.section)
                }
            } else {
                updateSumAtSection(indexPath!.section)
                updateSumAtSection(newIndexPath!.section)
            }
            
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            if  self.sectionOpened == newIndexPath!.section {
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
        }
    }
    
    func updateSumAtSection(section: Int) {
        if let header = self.tableView.headerViewForSection(section) as? RecordSectionHeader {
            let sum = getSumAtSection(section)
            header.sumLabel?.text = String(sum)
        }
    }
    
    func getSumAtSection(section: Int) -> Double {
        let dayRecords = self.fetchedResultsController.sections![section].objects as! [Record]
        let sum = dayRecords.reduce(0.0) { sum, record in
            sum + record.number
        }
        return sum
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func getDataIndexPathFrom(tableIndexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: tableIndexPath.row - 1, inSection: tableIndexPath.section)
    }
    
    func getTableIndexPathFrom(dataIndexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: dataIndexPath.row + 1, inSection: dataIndexPath.section)
    }
    
    // MARK: RecordSectionHeaderDelegate
    
    func openSection(sectionToOpen: Int) {
        self.tableView.beginUpdates()
        
        let indexPathsToInsert = getIndexPathsToInsert(sectionToOpen)
        var indexPathsToDelete = [NSIndexPath]()
        
        if let previousOpendedSection = self.sectionOpened {
            indexPathsToDelete = getIndexPathsToDelete(previousOpendedSection)
            let previousHeader = self.tableView.headerViewForSection(previousOpendedSection) as! RecordSectionHeader
            previousHeader.disclosureButton.selected = !previousHeader.disclosureButton.selected
        }
        
        self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Fade)
        self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Fade)
        
        self.sectionOpened = sectionToOpen
        self.tableView.endUpdates()
    }
    
    
    func getIndexPathsToInsert(sectionToOpen: Int) -> [NSIndexPath] {
        var indexPathsToInsert = [NSIndexPath]()
        for row in 0..<self.fetchedResultsController.sections![sectionToOpen].numberOfObjects {
            indexPathsToInsert.append(NSIndexPath(forRow: row, inSection: sectionToOpen))
        }
        return indexPathsToInsert
    }
    
    func closeSection(sectionToClose: Int) {
        if let sectionOpened = self.sectionOpened where sectionOpened == sectionToClose {
            self.sectionOpened = nil
            let indexPathsToDelete = getIndexPathsToDelete(sectionOpened)
            self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Fade)
        } else {
            fatalError("Section \(sectionToClose) not opended")
        }
    }
    
    func getIndexPathsToDelete(sectionToClose: Int) -> [NSIndexPath] {
        var indexPathsToDelete = [NSIndexPath]()
        for row in 0..<self.fetchedResultsController.sections![sectionToClose].numberOfObjects {
            indexPathsToDelete.append(NSIndexPath(forRow: row, inSection: sectionToClose))
        }
        return indexPathsToDelete
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let recordViewController = segue.destinationViewController as! EditRecordViewController
            let selectedRecordCell = sender as! RecordTableViewCell
            let cellIndexPath = tableView.indexPathForCell(selectedRecordCell)!
            let record = self.fetchedResultsController.objectAtIndexPath(cellIndexPath) as! Record
            recordViewController.record = record
        }
    }
}
