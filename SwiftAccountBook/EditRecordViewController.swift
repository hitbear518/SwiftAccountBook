//
//  RecordViewController2.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class EditRecordViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var activeView: UIView?
    
    var record: Record!
    var isPayment = true
    
    var currentDate = NSDate() {
        didSet {
            footer.dateButton.setTitle(NSDateFormatter.localizedStringFromDate(currentDate, dateStyle: .FullStyle, timeStyle: .NoStyle), forState: .Normal)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var header: EditRecordViewControllerHeader!
    weak var footer: EditRecordViewControllerFooter!
    
    let secondsOneDay: NSTimeInterval = 24 * 60 * 60
    
    var savedTags: [Tag]!
    var savedTagNames: [String] {
        return savedTags.map { $0.name }
    }
    
    let presentDatePickerTransitioningDelegate = PresentDatePickerTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        registerForKeyboardNotification()
        loadTags()
        
        if self.record == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        }
    }
    
    func loadTags() {
        let request = NSFetchRequest(entityName: "Tag")
        do {
            self.savedTags = try MyDataController.context.executeFetchRequest(request) as! [Tag]
        } catch {
            fatalError("Failed to load tags: \(error)")
        }
    }
    
    func registerForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(aNotification: NSNotification) {
        guard let activeView = activeView else {
            return
        }
        let userInfo = aNotification.userInfo!
        let kbSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        var visibleRectOfCollectionView = collectionView.bounds
        visibleRectOfCollectionView.size.height -= kbSize.height
        visibleRectOfCollectionView.size.height -= visibleRectOfCollectionView.origin.y
        let activeViewFrameInCollectionView = activeView.superview!.convertRect(activeView.frame, toView: collectionView)
        var activeViewBottomPoint = activeViewFrameInCollectionView.origin
        activeViewBottomPoint.y += activeViewFrameInCollectionView.height
        
        if collectionView.contentInset.bottom == bottomLayoutGuide.length && !CGRectContainsPoint(visibleRectOfCollectionView, activeViewBottomPoint){
            self.collectionView.contentInset.bottom += kbSize.height
            self.collectionView.scrollIndicatorInsets.bottom += kbSize.height
            collectionView.scrollRectToVisible(activeViewFrameInCollectionView, animated: true)
        }
    }
    
    func keyboardWillHide(aNotification: NSNotification) {
        guard activeView != nil else {
            return
        }
        let userInfo = aNotification.userInfo!
        let kbSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        
        collectionView.contentInset.bottom -= kbSize.height
        collectionView.scrollIndicatorInsets.bottom -= kbSize.height
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? DatePickerViewController {
            destinationViewController.modalPresentationStyle = .Custom
            destinationViewController.transitioningDelegate = presentDatePickerTransitioningDelegate
        }
        
        if let _ = segue.destinationViewController as? DayRecordCollectionTableViewController {
            saveData()
        }
    }
    
    @IBAction func unwindToRecordViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.sourceViewController as? DatePickerViewController {
            currentDate = sourceViewController.datePicker.date
        }
    }
    
    func saveTags() {
        let success = NSKeyedArchiver.archiveRootObject(savedTags, toFile: Constants.TagArchiveURL.path!)
        if !success {
            print("save tags failed")
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    func getRecordTags() -> Set<Tag> {
        let tagNamesFromText = getTagNamesFromText()
        var recordTags = Set<Tag>()
        for tagName in tagNamesFromText {
            if let index = self.savedTags.indexOf({ $0.name == tagName}) {
                recordTags.insert(self.savedTags[index])
            } else {
                let newTag = NSEntityDescription.insertNewObjectForEntityForName("Tag", inManagedObjectContext: MyDataController.context) as! Tag
                newTag.name = tagName
                recordTags.insert(newTag)
            }
        }
        return recordTags
    }
    
    func saveData() {
        let recordTags = getRecordTags()
        let cost = Double(self.header.costTextField.text!)!
        let detail = self.footer.detailTextView.text
        let date = self.currentDate
        let dayInEra = Utils.calendar.ordinalityOfUnit(.Day, inUnit: .Era, forDate: date)
        
        // Clear belongedCollection info if needed
        if self.record != nil && self.record.dayInEra != dayInEra {
            let oldDayCollection = self.record.belongedCollection
            oldDayCollection.records.remove(self.record)
            if oldDayCollection.records.isEmpty {
                MyDataController.context.deleteObject(oldDayCollection)
            }
        }
        
        if self.record == nil {
            self.record = NSEntityDescription.insertNewObjectForEntityForName("Record", inManagedObjectContext: MyDataController.context) as! Record
        }
        // set record info
        self.record.tags = recordTags
        self.record.number = cost
        self.record.detail = detail
        
        if self.record.dayInEra != dayInEra {
            self.record.date = date
            self.record.dayInEra = dayInEra
            // set belongedCollection
            var belongedCollection: DayRecordCollection!
            let dayCostRequest = NSFetchRequest(entityName: "DayRecordCollection")
            dayCostRequest.predicate = NSPredicate(format: "dayInEra == %d", dayInEra)
            do {
                let matchingDayRecordCollections = try MyDataController.context.executeFetchRequest(dayCostRequest) as! [DayRecordCollection]
                belongedCollection = matchingDayRecordCollections.first
            } catch {
                fatalError("Request matching DayRecordCollection of dayInEra \(dayInEra) for record failed: \(error)")
            }
            if belongedCollection == nil {
                belongedCollection = NSEntityDescription.insertNewObjectForEntityForName("DayRecordCollection", inManagedObjectContext: MyDataController.context) as! DayRecordCollection
                belongedCollection.date = date
                belongedCollection.dayInEra = dayInEra
                belongedCollection.records = Set<Record>()
            }
            belongedCollection.records.insert(self.record)
        } else {
            // Trigger NSFetchedResultsController update
            self.record.belongedCollection.dayInEra = self.record.belongedCollection.dayInEra
        }
        
        MyDataController.save()
    }
    
    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        return savedTags.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCollectionViewCell", forIndexPath: indexPath) as! TagCollectionViewCell
    
        // Configure the cell
        cell.tagNameLabel.text = savedTags[indexPath.row].name
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let inputAccessoryView = UIToolbar()
        inputAccessoryView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        inputAccessoryView.setItems([flexibleSpace, doneButton], animated: false)
        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "EditRecordViewControllerHeader", forIndexPath: indexPath) as! EditRecordViewControllerHeader
            header.costTextField.delegate = self
            header.costTextField.addTarget(self, action: "editingChanged:", forControlEvents: .EditingChanged)
            header.costTextField.inputAccessoryView = inputAccessoryView
            
            header.tagTextField.addTarget(self, action: "editingChanged:", forControlEvents: .EditingChanged)
            header.tagTextField.delegate = self
            if let record = record {
                header.costTextField.text = String(record.number)
                var tagsText = ""
                record.tags?.forEach { tag in
                    tagsText += "\(tag.name), "
                }
                header.tagTextField.text = tagsText
                
                if let tagNames = record.tags?.map({ tag -> String in tag.name }) {
                    syncCollectionViewSelectionFromInUseTagNames(tagNames)
                }
            } else {
                syncCollectionViewSelectionFromInUseTagNames([])
            }
            syncSaveButtonEnabled()
            return header
        } else {
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "EditRecordViewControllerFooter", forIndexPath: indexPath) as! EditRecordViewControllerFooter
            footer.detailTextView.delegate = self
            footer.detailTextView.inputAccessoryView = inputAccessoryView
            if let record = record {
                footer.detailTextView.text = record.detail
                currentDate = record.date
            }
            let calendar = NSCalendar.currentCalendar()
            if calendar.isDateInToday(currentDate) {
                footer.dateSegmentedControl.selectedSegmentIndex = 1
                footer.dateButton.hidden = true
            } else if calendar.isDateInYesterday(currentDate) {
                footer.dateSegmentedControl.selectedSegmentIndex = 0
                footer.dateButton.hidden = true
            } else {
                footer.dateSegmentedControl.selectedSegmentIndex = 2
                footer.dateButton.hidden = false
            }
            footer.dateSegmentedControl.addTarget(self, action: "dateSegmentedValueChanged:", forControlEvents: .ValueChanged)
            return footer
        }
    }
    
    
    func doneButtonTapped(doneButton: UIButton) {
        activeView?.resignFirstResponder()
    }
    
    // MARK: UITextField UIControlEvent monitor
    func editingChanged(sender: UITextField) {
        syncSaveButtonEnabled()
        guard sender === header.tagTextField else { return }
        let tagNamesFromText = getTagNamesFromText()
        syncCollectionViewSelectionFromInUseTagNames(tagNamesFromText)
    }
    
    func syncCollectionViewSelectionFromInUseTagNames(inUseTagNames: [String]) {
        for var row = 0; row < collectionView.numberOfItemsInSection(0); row++ {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
            let cellTagName = cell.tagNameLabel.text!
            if inUseTagNames.contains(cellTagName) {
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                cell.tagNameLabel.textColor = UIColor.whiteColor()
                cell.tagNameLabel.backgroundColor = Constants.defaultRedColor
            } else {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                cell.tagNameLabel.textColor = Constants.defaultRedColor
                cell.tagNameLabel.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    func getTagNamesFromText() -> [String] {
        let usedTagsText = header.tagTextField.text!
        let usedTagNames = usedTagsText.characters.split{$0 == ","}.map(String.init)
            .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())}
            .filter {!$0.isEmpty}
        return usedTagNames
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeView = textField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === header.costTextField {
            
            var text = textField.text!
            let range = text.startIndex.advancedBy(range.location)..<text.startIndex.advancedBy(range.location + range.length)
            text.replaceRange(range, with: string)
            var dotCount = 0
            for c in text.characters {
                if c == "." {
                    ++dotCount
                }
            }
            return dotCount <= 1
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeView = textField
    }
    
    func checkValidRecordTag() -> Bool {
        let tag = header.tagTextField.text ?? ""
        return !tag.isEmpty
    }
    
    func checkValidRecordNumber() -> Bool {
        let number = Double(header.costTextField.text!) ?? 0.0
        return number > 0.0
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeView = textView
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeView = nil
    }
    
    // MARK: SegmentedControl event
    func dateSegmentedValueChanged(sender: UISegmentedControl) {
        
        let selectedIndex = footer.dateSegmentedControl.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            let yestoday = NSDate(timeIntervalSinceNow: -secondsOneDay)
            currentDate = yestoday
            footer.dateButton.hidden = true
        case 1:
            let today = NSDate()
            currentDate = today
            footer.dateButton.hidden = true
        default:
            footer.dateButton.hidden = false
            performSegueWithIdentifier("PresentDatePicker", sender: self)
            
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSizeZero
        size.width = view.frame.width
        size.height = 72
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var size = CGSizeZero
        size.width = view.frame.width
        size.height = 140
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let label = UILabel()
        label.text = savedTags[indexPath.row].name
        label.sizeToFit()
        label.frame.size.height += 16
        label.frame.size.width += 16
        if label.frame.size.width < 44.0 {
            label.frame.size.width = 44.0
        }
        return label.frame.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(16, 0, 16, 0)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        cell.tagNameLabel.textColor = UIColor.whiteColor()
        cell.tagNameLabel.backgroundColor = Constants.defaultRedColor
        
        var tagsText = header.tagTextField.text!
        tagsText = tagsText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if !header.tagTextField.text!.hasSuffix(", ")  && !tagsText.isEmpty{
            header.tagTextField.text! += ", "
        }
        
        header.tagTextField.text! += "\(cell.tagNameLabel.text!), "
        
        syncSaveButtonEnabled()
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        cell.tagNameLabel.textColor = UIColor.whiteColor()
        cell.tagNameLabel.backgroundColor = Constants.defaultRedColor
        cell.alpha = 0.6
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems() where selectedIndexPaths.contains(indexPath) {
            cell.tagNameLabel.textColor = UIColor.whiteColor()
        } else {
            cell.tagNameLabel.textColor = Constants.defaultRedColor
        }
        cell.alpha = 1.0
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        cell.tagNameLabel.textColor = Constants.defaultRedColor
        cell.tagNameLabel.backgroundColor = UIColor.clearColor()
        
        let tagsFromText = getTagNamesFromText()
        let remainingTags = tagsFromText.filter {!($0 == cell.tagNameLabel.text!)}
        
        var remainingTagsText = String()
        for tag in remainingTags {
            remainingTagsText += "\(tag), "
        }
        
        header.tagTextField.text = remainingTagsText
        syncSaveButtonEnabled()
    }
    
    func syncSaveButtonEnabled() {
        saveButton.enabled = checkValidRecordNumber() && checkValidRecordTag()
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
}
