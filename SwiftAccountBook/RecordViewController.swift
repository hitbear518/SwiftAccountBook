//
//  RecordViewController2.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/2.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var activeView: UIView?
    var record: Record?
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var header: RecordViewControllerHeader!
    weak var footer: RecordViewControllerFooter!
    
    let secondsOneDay: NSTimeInterval = 24 * 60 * 60
    
    var savedTags = [String]()

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
        
        if let savedTags = loadSavedTags() {
            self.savedTags = savedTags
        }
    }
    
    func loadSavedTags() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.TagArchiveURL.path!) as? [String]
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
        
        if collectionView.contentInset.bottom == bottomLayoutGuide.length {
            self.collectionView.contentInset.bottom += kbSize.height
            self.collectionView.scrollIndicatorInsets.bottom += kbSize.height
        }
        
        var visibleRectInCollectionView = collectionView.frame
        visibleRectInCollectionView.size.height -= kbSize.height
        let activeViewFrameInCollectionView = activeView.convertRect(activeView.bounds, toView: collectionView)
        var activeViewBottomPoint = activeViewFrameInCollectionView.origin
        activeViewBottomPoint.y += activeViewFrameInCollectionView.height
        if !CGRectContainsPoint(visibleRectInCollectionView, activeViewBottomPoint) {
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if sender === saveButton {
            let tagsFromText = getTagsFromText()
            record = Record(number: Double(header.numberTextField.text!)!, tags: tagsFromText, date: footer.datePicker.date, recordDescription: footer.recordDescriptionTextView.text)
            for tag in tagsFromText {
                if !savedTags.contains(tag) {
                    savedTags.append(tag)
                }
            }
            saveTags()
        }
    }
    
    func saveTags() {
        let success = NSKeyedArchiver.archiveRootObject(savedTags, toFile: Constants.TagArchiveURL.path!)
        if !success {
            print("save tags failed")
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return savedTags.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TagCollectionViewCell", forIndexPath: indexPath) as! TagCollectionViewCell
    
        // Configure the cell
        cell.tagNameLabel.text = savedTags[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let inputAccessoryView = UIToolbar()
        inputAccessoryView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        inputAccessoryView.setItems([flexibleSpace, doneButton], animated: false)
        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "RecordViewControllerHeader", forIndexPath: indexPath) as! RecordViewControllerHeader
            header.numberTextField.delegate = self
            header.numberTextField.addTarget(self, action: "editingChanged:", forControlEvents: .EditingChanged)
            header.numberTextField.inputAccessoryView = inputAccessoryView
            
            header.tagTextField.addTarget(self, action: "editingChanged:", forControlEvents: .EditingChanged)
            header.tagTextField.delegate = self
            if let record = record {
                header.numberTextField.text = String(record.number)
                var tagsText = ""
                for tag in record.tags {
                    tagsText += "\(tag), "
                }
                header.tagTextField.text = tagsText
                
                syncCollectionViewSelectionFromInUseTags(record.tags)
            }
            syncSaveButtonEnabled()
            return header
        } else {
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "RecordViewControllerFooter", forIndexPath: indexPath) as! RecordViewControllerFooter
            footer.recordDescriptionTextView.delegate = self
            footer.recordDescriptionTextView.inputAccessoryView = inputAccessoryView
            if let record = record {
                footer.datePicker.date = record.date
                footer.recordDescriptionTextView.text = record.recordDescription
            }
            let calendar = NSCalendar.currentCalendar()
            if calendar.isDateInToday(footer.datePicker.date) {
                footer.dateSegmentedControl.selectedSegmentIndex = 1
                footer.dateStackView.hidden = true
            } else if calendar.isDateInYesterday(footer.datePicker.date) {
                footer.dateSegmentedControl.selectedSegmentIndex = 0
                footer.dateStackView.hidden = true
            } else {
                footer.dateSegmentedControl.selectedSegmentIndex = 2
                footer.dateStackView.hidden = false
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
        let tagsFromText = getTagsFromText()
        syncCollectionViewSelectionFromInUseTags(tagsFromText)
    }
    
    func syncCollectionViewSelectionFromInUseTags(inUseTags: [String]) {
        for var row = 0; row < collectionView.numberOfItemsInSection(0); row++ {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
            let cellTag = cell.tagNameLabel.text!
            if inUseTags.contains(cellTag) {
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                cell.tagNameLabel.textColor = UIColor.whiteColor()
            } else {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                cell.tagNameLabel.textColor = UIColor(red: 0.0, green: 118.0 / 225.0 , blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    func getTagsFromText() -> [String] {
        let usedTagsText = header.tagTextField.text!
        let usedTags = usedTagsText.characters.split{$0 == ","}.map(String.init)
            .map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())}
            .filter {!$0.isEmpty}
        return usedTags
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeView = textField
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField === header.numberTextField {
            
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
        let number = Double(header.numberTextField.text!) ?? 0.0
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
        print("before: \(self.footer.dateStackView.hidden)")
        switch selectedIndex {
        case 0:
            let yestoday = NSDate(timeIntervalSinceNow: -secondsOneDay)
            footer.datePicker.date = yestoday
            if footer.dateStackView.hidden == false {
                UIView.transitionWithView(footer.dateStackView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    self.footer.dateStackView.alpha = 0.0
                    self.footer.dateStackView.hidden = true
                    }, completion: nil)
            }
        case 1:
            let today = NSDate()
            footer.datePicker.date = today
            if footer.dateStackView.hidden == false {
                UIView.transitionWithView(footer.dateStackView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                    self.footer.dateStackView.hidden = true
                    self.footer.dateStackView.alpha = 0.0
                    }, completion: nil)
            }
        default:
            UIView.transitionWithView(footer.dateStackView, duration: 0.3, options: .TransitionCrossDissolve, animations: {
                self.footer.dateStackView.hidden = false
                self.footer.dateStackView.alpha = 1.0
                }, completion: nil)
        }
    }
    
    // MARK: UICoolectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSizeZero
        size.width = view.frame.width
        size.height = 72
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var size = CGSizeZero
        size.width = view.frame.width
        size.height = 450
        return size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let label = UILabel()
        label.text = savedTags[indexPath.row]
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
        cell.alpha = 0.6
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        cell.tagNameLabel.textColor = UIColor(red: 0.0, green: 118.0 / 255.0, blue: 1.0, alpha: 1)
        
        let tagsFromText = getTagsFromText()
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
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagCollectionViewCell
        cell.tagNameLabel.textColor = UIColor(red: 0.0, green: 118.0 / 255.0, blue: 1.0, alpha: 1)
        cell.alpha = 1.0
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
