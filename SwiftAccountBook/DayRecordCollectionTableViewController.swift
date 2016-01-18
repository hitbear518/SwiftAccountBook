//
//  RecordTableViewController2.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit
import CoreData

class DayRecordCollectionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, DayRecordCollectionTableViewCellDelegate {
    
    var fetchedResultsController: NSFetchedResultsController!
    var openedIndexPath: NSIndexPath? = NSIndexPath(forRow: 0, inSection: 0)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        initializeFetchedResultsController()
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "DayRecordCollection")
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [dateSortDescriptor]
        
        let lastMonth = Utils.calendar.dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: [])!
        let components = Utils.calendar.components([.Month, .Year], fromDate: lastMonth)
        components.day = 1
        let lastMonthStart = Utils.calendar.dateFromComponents(components)!
        request.predicate = NSPredicate(format: "date >= %@", lastMonthStart)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: MyDataController.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to load DayRecordCollection: \(error)")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard self.fetchedResultsController != nil else { return 0 }
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.fetchedResultsController != nil else { return 0 }
        return self.fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DayRecordCollectionCell", forIndexPath: indexPath) as! DayRecordCollectionTableViewCell

        // Configure the cell...
        let dayRecordCollection = self.fetchedResultsController.objectAtIndexPath(indexPath) as! DayRecordCollection
        cell.configCell(dayRecordCollection, opened: self.openedIndexPath == indexPath)
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
            if let openedIndexPath = self.openedIndexPath where newIndexPath!.row <= openedIndexPath.row {
                self.openedIndexPath = NSIndexPath(forRow: openedIndexPath.row + 1, inSection: openedIndexPath.section)
            }
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            if self.openedIndexPath == indexPath {
                self.openedIndexPath = nil
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

    // MARK: DayRecordCollectionTableViewCellDelegate
    
    func dayRecordCollectionDidTapAtCell(cell: DayRecordCollectionTableViewCell) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        
        if let openedIndexPath = self.openedIndexPath {
            var indexPathsToReload = [NSIndexPath]()
            if openedIndexPath == indexPath {
                self.openedIndexPath = nil
            } else {
                self.openedIndexPath = indexPath
                indexPathsToReload.append(openedIndexPath)
            }
            
            indexPathsToReload.append(indexPath)
            self.tableView.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Fade)
        } else {
            self.openedIndexPath = indexPath
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func recordDidTap(record: Record) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = mainStoryBoard.instantiateViewControllerWithIdentifier("ViewRecordViewController") as! ViewRecordViewController
        vc.record = record
        showViewController(vc, sender: self)
    }
    
    // MARK: - Navigation
    @IBAction func unwindFromEditRecord(segue: UIStoryboardSegue) {
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
