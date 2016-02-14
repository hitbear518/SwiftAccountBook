//
//  BalanceViewControllerTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/2/7.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit
import CoreData

class BalanceTableViewController: UITableViewController {

    @IBOutlet weak var lastMonthBalanceLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    
    var originalStartDay = Settings.startDay
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        lastMonthBalanceLabel.textColor = Theme.Default.mainColor
        currentBalanceLabel.textColor = Theme.Default.mainColor
        incomeLabel.textColor = Theme.Income.mainColor
        paymentLabel.textColor = Theme.Payment.mainColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateData()
    }
    
    private func updateData() {
        let startDate = NSCalendar.currentCalendar().nextDateAfterDate(NSDate(), matchingUnit: .Day, value: Settings.startDay, options: [.SearchBackwards, .MatchPreviousTimePreservingSmallerUnits])!
        let startDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: startDate)
        let endDayInEra = NSCalendar.currentCalendar().ordinalityOfUnit(.Day, inUnit: .Era, forDate: NSDate())
        
        let toLastMonthSum: Double
        
        let fetch = NSFetchRequest(entityName: "Record")
        fetch.predicate = NSPredicate(format: "dayInEra < %d", startDayInEra)
        do {
            let toLastMonthRecords = try MyDataController.context.executeFetchRequest(fetch) as! [Record]
            toLastMonthSum = toLastMonthRecords.reduce(0.0) { sum, record in
                if record.isPayment {
                    return sum - record.number
                } else {
                    return sum + record.number
                }
            }
            lastMonthBalanceLabel.text = NSNumberFormatter.localizedStringFromNumber(toLastMonthSum, numberStyle: .CurrencyStyle)
        } catch let error as NSError {
            fatalError("Faled to fetch toLastMonthRecords: \(error.localizedDescription)")
        }
        
        fetch.predicate = NSPredicate(format: "(dayInEra >= %d) AND (dayInEra <= %d)", startDayInEra, endDayInEra)
        do {
            let thisMonthRecords = try MyDataController.context.executeFetchRequest(fetch) as! [Record]
            let thisMonthPayment = thisMonthRecords.reduce(0.0) { sum, record in
                if record.isPayment {
                    return sum + record.number
                } else {
                    return sum
                }
            }
            let thisMonthIncome = thisMonthRecords.reduce(0.0) { sum, record in
                if !record.isPayment {
                    return sum + record.number
                } else {
                    return sum
                }
            }
            
            incomeLabel.text = NSNumberFormatter.localizedStringFromNumber(thisMonthIncome, numberStyle: .CurrencyStyle)
            paymentLabel.text = NSNumberFormatter.localizedStringFromNumber(thisMonthPayment, numberStyle: .CurrencyStyle)
            let currentBalance = toLastMonthSum + thisMonthIncome - thisMonthPayment
            currentBalanceLabel.text = NSNumberFormatter.localizedStringFromNumber(currentBalance, numberStyle: .CurrencyStyle)
        } catch let error as NSError {
            fatalError("Faled to fetch thisMonthRecords: \(error.localizedDescription)")
        }
    }

    // MARK: - Table view data source
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
