//
//  StatisticsTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/4.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class StatisticsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let nextImage = UIImage(named: "forward_button_image")!
        let label = nextButton.titleLabel!
        label.sizeToFit()
        
        let imageLeftInset = nextButton.frame.width - nextButton.imageView!.frame.width
        nextButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, imageLeftInset, 0.0, 0.0)
        nextButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, nextImage.size.width)
        nextButton.titleLabel?.sizeToFit()
        
        
        endingDate = now
        
        initializeFetchedResultsController()
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print(self.intervalLabel.superview)
    }
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Tag")
        let tagNameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [tagNameSortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to load tags: \(error)")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startingDay = NSUserDefaults.standardUserDefaults().integerForKey("StartingDay")
        updateDateInfo()
    }
    
    func updateDateInfo() {
        if startingDate == nil {
            if let match = calendar.nextDateAfterDate(endingDate, matchingUnit: .Day, value: Settings.startDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits]) {
                startingDate = match
            } else {
                fatalError("find matching startingDate failed")
            }
        } else {
            if let match = calendar.nextDateAfterDate(startingDate, matchingUnit: .Day, value: Settings.startDay, options: [.MatchPreviousTimePreservingSmallerUnits]) {
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
        
        self.tableView.reloadData()
    }
    
    func isDateThisMonth(date: NSDate) -> Bool {
        var start: NSDate?
        var extends: NSTimeInterval = 0
        let success = calendar.rangeOfUnit(.Month, startDate: &start, interval: &extends, forDate: NSDate())
        if !success {
            return false
        }
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
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections![section].numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatisticsTableViewCell", forIndexPath: indexPath) as! StatisticsTableViewCell
        
        // Configure the cell...
        let tag = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Tag
        cell.tagLabel.text = tag.name
        
        do {
            if startingDate != nil && endingDate != nil {
                let recordsRequest = NSFetchRequest(entityName: "Record")
                let startDayInEra = calendar.ordinalityOfUnit(.Day, inUnit: .Era, forDate: startingDate)
                let endDayInEra = calendar.ordinalityOfUnit(.Day, inUnit: .Era, forDate: endingDate)
                recordsRequest.predicate = NSPredicate(format: "(ANY tags.name == %@) && (dayInEra >= %d) && (dayInEra <= %d)", tag.name, startDayInEra, endDayInEra)
                let records = try self.moc.executeFetchRequest(recordsRequest) as! [Record]
                let sum = records.reduce(0.0) { sum, record in
                    sum + record.number
                }
                cell.sumLabel.text = String(sum)
            }
        } catch {
            fatalError("Fetch records failed")
        }

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
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
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
