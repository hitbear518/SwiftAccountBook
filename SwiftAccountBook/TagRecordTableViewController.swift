//
//  TagRecordTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/20.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit
import CoreData

class TagRecordTableViewController: UITableViewController {
    
    var startDate, endDate: NSDate!
    var fetchedResultsController: NSFetchedResultsController!
    var isPayment: Bool!
    var openedCellIndexPath: NSIndexPath?
    var tableHeader: TableHeader?

    override func viewDidLoad() {
        super.viewDidLoad()

        if startDate == nil {
            startDate = NSCalendar.currentCalendar().nextDateAfterDate(endDate, matchingUnit: .Day, value: Settings.startDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits])
        }
        
        initializeFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count > 0 {
            openedCellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        }
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableHeader = NSBundle.mainBundle().loadNibNamed("TableHeader", owner: nil, options: nil).first as? TableHeader
        tableView.tableHeaderView = tableHeader
        let startDateStr = Utils.getDateStr(startDate, dateStyle: .MediumStyle)
        let endDateStr = Utils.getDateStr(endDate, dateStyle: .MediumStyle)
        tableHeader?.dateRangeLabel.text = "\(startDateStr) - \(endDateStr)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let startDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: self.startDate)
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: self.endDate)
        let request = NSFetchRequest(entityName: "Record")
        request.predicate = NSPredicate(format: "(dayInEra >= %d) AND (dayInEra <= %d) AND (isPayment == %@)", startDayInEra, endDayInEra, isPayment)
        
        do {
            let records = try MyDataController.context.executeFetchRequest(request) as! [Record]
            let recordSum = records.reduce(0.0) { sum, record in
                sum + record.number
            }
            let sumStr = NSNumberFormatter.localizedStringFromNumber(recordSum, numberStyle: .CurrencyStyle)
            self.navigationController?.topViewController?.navigationItem.title = "总计 \(sumStr)"
        } catch let error as NSError {
            fatalError("Fetch records failed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
        tableView.contentInset = edgeInsets
        tableView.scrollIndicatorInsets = edgeInsets
    }
    
    private func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Tag")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        let startDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: startDate)
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: endDate)
        
        let startToEndArr = [Int](startDayInEra...endDayInEra)
        request.predicate = NSPredicate(format: "(ofPayment == %@) AND (ANY records.dayInEra IN %@)", isPayment, startToEndArr)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: MyDataController.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("Init fetchedResultsController faileld: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("rows(tag record): \(fetchedResultsController.sections![section].numberOfObjects)")
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagRecordCell", forIndexPath: indexPath) as! TagRecordTableViewCell

        let tag = fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        let request = NSFetchRequest(entityName: "Record")
        let startDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: startDate)
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: endDate)
        let startToEndArray = [Int](startDayInEra...endDayInEra)
        request.predicate = NSPredicate(format: "(ANY tags.name == %@) && (dayInEra IN %@)" , tag.name, startToEndArray)
        do {
            let records = try MyDataController.context.executeFetchRequest(request) as! [Record]
            cell.configCell(tag, records: records, opened: openedCellIndexPath == indexPath)
            cell.delegate = self
        } catch let error as NSError {
            fatalError("Request records for tag \(tag.name) failed: \(error.localizedDescription)")
        }
        
        return cell
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

// MARK: - NSFetchedResultsControllerDelegate

extension TagRecordTableViewController: NSFetchedResultsControllerDelegate {
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
}
extension TagRecordTableViewController: RecordTableViewCellDelegate {
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