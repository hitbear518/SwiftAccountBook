//
//  EditTagTableViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/14.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class EditTagTableViewController: UITableViewController, EditTagTableViewCellDelegate {
    var recordsArray = [[Record]]()
    var tags = [String]()
    var tagRecordsCountTuples = [(tag: String, recordsCount: Int)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem()
        
        
        if let recordsArray = loadRecords() {
            self.recordsArray = recordsArray
        }
        
        if let tags = loadTags() {
            self.tags = tags
            tags.forEach { tag in tagRecordsCountTuples.append((tag, 0))}
        }
        
        let allRecords = recordsArray.flatMap { $0 }
        for (index, tuple) in tagRecordsCountTuples.enumerate() {
            let recordsCountForTag = allRecords.filter({ $0.tags.contains(tuple.tag) }).count
            tagRecordsCountTuples[index].recordsCount = recordsCountForTag
        }
    }
    
    func loadRecords() -> [[Record]]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Record.ArchiveURL.path!) as? [[Record]]
    }
    
    func loadTags() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.TagArchiveURL.path!) as? [String]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tagRecordsCountTuples.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditTagCell", forIndexPath: indexPath) as! EditTagTableViewCell
        let tuple = tagRecordsCountTuples[indexPath.row]
        // Configure the cell...
        cell.configCell(tuple)
        cell.delegate = self

        return cell
    }
    
    // MARK: EditTagTableViewCellDelegate
    func tagDidEndEditing(before: String, after: String) {
        for (section, records) in recordsArray.enumerate() {
            for (row, record) in records.enumerate() {
                for (tagIndex, tag) in record.tags.enumerate() {
                    if tag == before {
                        recordsArray[section][row].tags[tagIndex] = after
                    }
                }
            }
        }
        
        for (index, tag) in tags.enumerate() {
            if tag == before {
                tags[index] = after
            }
        }
        
        saveRecords()
        saveTags()
    }
    
    func saveRecords() {
        NSKeyedArchiver.archiveRootObject(recordsArray, toFile: Record.ArchiveURL.path!)
    }
    
    func saveTags() {
        NSKeyedArchiver.archiveRootObject(tags, toFile: Constants.TagArchiveURL.path!)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            deleteTag(tagRecordsCountTuples[indexPath.row].tag)
            tagRecordsCountTuples.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func deleteTag(tag: String) {
        for (section, records) in recordsArray.enumerate() {
            for (row, record) in records.enumerate() {
                recordsArray[section][row].tags = record.tags.filter { $0 != tag }
            }
            recordsArray[section] = records.filter { !$0.tags.isEmpty }
        }
        recordsArray = recordsArray.filter { !$0.isEmpty }
        saveRecords()
        
        tags = tags.filter { $0 != tag }
        saveTags()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
