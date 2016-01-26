//
//  RecordTableViewController2.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit
import CoreData

class DayRecordTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var startDate, endDate: NSDate!
    var isPayment: Bool!
    var fetchedResultsController: NSFetchedResultsController!
    var openedCellIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        if self.startDate == nil {
            self.startDate = NSCalendar.currentCalendar().nextDateAfterDate(self.endDate, matchingUnit: .Day, value: Settings.startDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits])
        }
        
        initializeFetchedResultsController()
        if self.fetchedResultsController.fetchedObjects!.count > 0 {
            self.openedCellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        }
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let startDateStr = NSDateFormatter.localizedStringFromDate(self.startDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        let endDateStr = Utils.getDateStr(endDate, dateStyle: .ShortStyle)
        self.navigationController?.topViewController?.navigationItem.title = "\(startDateStr) - \(endDateStr)"
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "DayRecords")
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        let startDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: self.startDate)
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: self.endDate)
        request.predicate = NSPredicate(format: "(dayInEra >= %d) && (dayInEra <= %d) && (ANY records.isPayment == %@)", startDayInEra, endDayInEra, self.isPayment)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: MyDataController.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to load DayRecordCollection: \(error)")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: self.bottomLayoutGuide.length, right: 0)
        self.tableView.contentInset = edgeInsets
        self.tableView.scrollIndicatorInsets = edgeInsets
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("rows: \(self.fetchedResultsController.sections![section].numberOfObjects)")
        return self.fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayRecordCell", forIndexPath: indexPath) as! DayRecordTableViewCell

        // Configure the cell...
        let dayRecords = self.fetchedResultsController.objectAtIndexPath(indexPath) as! DayRecords
        cell.configCell(dayRecords, isPayment: isPayment, opened: openedCellIndexPath == indexPath)
        cell.delegate = self

        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let openedIndexPath = self.openedCellIndexPath where newIndexPath!.row <= openedIndexPath.row {
                self.openedCellIndexPath = NSIndexPath(forRow: openedIndexPath.row + 1, inSection: openedIndexPath.section)
            }
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            if self.openedCellIndexPath == indexPath {
                self.openedCellIndexPath = nil
            }
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    // MARK: - Navigation
    @IBAction func unwindFromEditRecord(segue: UIStoryboardSegue) {
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let destinationViewController = segue.destinationViewController as? EditRecordViewController {
            destinationViewController.isPayment = true
        }
    }
}

extension DayRecordTableViewController: RecordTableViewCellDelegate {
    // MARK: DayRecordTableViewCellDelegate
    
    func sumViewDidTapAtCell(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        
        if let openedIndexPath = self.openedCellIndexPath {
            var indexPathsToReload = [NSIndexPath]()
            if openedIndexPath == indexPath {
                self.openedCellIndexPath = nil
            } else {
                self.openedCellIndexPath = indexPath
                indexPathsToReload.append(openedIndexPath)
            }
            
            indexPathsToReload.append(indexPath)
            self.tableView.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Fade)
        } else {
            self.openedCellIndexPath = indexPath
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func recordDidTap(record: Record) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = mainStoryBoard.instantiateViewControllerWithIdentifier("ViewRecordViewController") as! ViewRecordViewController
        vc.record = record
        if self.isPayment == true {
            self.navigationController?.childViewControllers.last?.navigationItem.title = "支出"
        } else {
            self.navigationController?.childViewControllers.last?.navigationItem.title = "收入"
        }
        showViewController(vc, sender: self)
    }
}