//
//  SettingsTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/5.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SettingsTableViewCellDelegate {
    
    var cellDescriptors: NSMutableArray!
    var visibleCellIndices = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadCellDescriptors()
        getVisibleCellIndices()
        tableView.reloadData()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadCellDescriptors() {
        if let path = NSBundle.mainBundle().pathForResource("SettingsCellDescriptors", ofType: "plist") {
            cellDescriptors = NSMutableArray(contentsOfFile: path)
        }
    }
    
    func getVisibleCellIndices() {
        visibleCellIndices.removeAll()
        for (index, cellDescriptor) in cellDescriptors.enumerate() {
            if cellDescriptor["visible"] as! Bool {
                visibleCellIndices.append(index)
            }
        }
    }
    
    func getPlistIndexAndDescriptorForCellAt(row: Int) -> (Int, AnyObject) {
        let plistIndex = visibleCellIndices[row]
        let cellDescriptor = cellDescriptors[plistIndex]
        return (plistIndex, cellDescriptor)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return visibleCellIndices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (_, currentCellDescriptor) = getPlistIndexAndDescriptorForCellAt(indexPath.row)
        let cellId = currentCellDescriptor["cellId"] as! String
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! SettingsTableViewCell
        cell.delegate = self

        switch cellId {
        case "StartingDaySettingCell":
            cell.detailTextLabel?.text = currentCellDescriptor["secondaryText"] as? String
        default:
            break
        }

        return cell
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
    
    // MARK: TableView delegate
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let (_, cellDescriptor) = getPlistIndexAndDescriptorForCellAt(indexPath.row)
//        let cellId = cellDescriptor["cellId"] as! String
//        switch cellId {
//        case "StartingDayPickerCell":
//            return 216.0
//        default:
//            return 44.0
//        }
//    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let (cellPlistIndex, selectedCellDescriptor) = getPlistIndexAndDescriptorForCellAt(indexPath.row)
        let expandable = selectedCellDescriptor["expandable"] as! Bool
        if expandable {
            var expanded = selectedCellDescriptor["expanded"] as! Bool
            expanded = !expanded
            selectedCellDescriptor.setValue(expanded, forKey: "expanded")
        
            let additionalRows = selectedCellDescriptor["additionalRows"] as! Int
            var additionalRowIndexPaths = [NSIndexPath]()
            for offset in 1...additionalRows  {
                cellDescriptors[cellPlistIndex + offset].setValue(expanded, forKey: "visible")
                additionalRowIndexPaths.append(NSIndexPath(forRow: indexPath.row + offset, inSection: 0))
            }
            getVisibleCellIndices()
            if expanded {
                tableView.insertRowsAtIndexPaths(additionalRowIndexPaths, withRowAnimation: .Fade)
            } else {
                tableView.deleteRowsAtIndexPaths(additionalRowIndexPaths, withRowAnimation: .Fade)
            }
        }
    }
    
    // MARK SettingsTableViewCellDelegate
    
    func pickerViewDidSelect(day: Int) {
        var startingDayString: String
        switch day {
        case 1:
            startingDayString = "1st Day"
        case 2:
            startingDayString = "2nd Day"
        default:
            startingDayString = "\(day)th Day"
        }
        cellDescriptors[1].setValue(startingDayString, forKey: "secondaryText")
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Fade)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
