//
//  ViewController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/10/17.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource {
    
    var record: Record?
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var dateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var recordDescriptionTextView: UITextView!
    weak var activeView: UIView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateStackView: UIStackView!
    let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    let secondsOneDay: NSTimeInterval = 24 * 60 * 60
    
    let testTags = ["tag", "short tag", "middle length tag", "tag", "tag", "very very very long tag", "tag", "tag33"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tagTextField.delegate = self
        numberTextField.delegate = self
        numberTextField.addTarget(self, action: "textDidChanged:", forControlEvents: .EditingChanged)
        tagTextField.addTarget(self, action: "textDidChanged:", forControlEvents: .EditingChanged)
        recordDescriptionTextView.delegate = self
        
        dateStackView.hidden = true
        if let record = record {
            tagTextField.text = record.tag
            numberTextField.text = String(record.number)
            datePicker.date = record.date
            if calendar.isDateInToday(record.date) {
                dateSegmentedControl.selectedSegmentIndex = 1
            } else if calendar.isDateInYesterday(record.date) {
                dateSegmentedControl.selectedSegmentIndex = 0
            } else {
                dateSegmentedControl.selectedSegmentIndex = 2
                dateStackView.hidden = false
            }
            recordDescriptionTextView.text = record.recordDescription
        }
        
        saveButton.enabled = checkValidRecordNumber() && checkValidRecordTag()
        
        registerForKeyboardNotification()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonTapped:")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flexibleSpace, doneButton], animated: false)
        
        numberTextField.inputAccessoryView = keyboardDoneButtonView
        recordDescriptionTextView.inputAccessoryView = keyboardDoneButtonView
        
        tagCollectionView.dataSource = self
    }
    
    func doneButtonTapped(doneButton: UIButton) {
        activeView?.resignFirstResponder()
    }
    
    // MARK: UITextField UIControlEvent monitor
    func textDidChanged(sender: UITextField) {
        saveButton.enabled = checkValidRecordNumber() && checkValidRecordTag()
    }

    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeView = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeView = textField
    }
    
    func checkValidRecordTag() -> Bool {
        let tag = tagTextField.text ?? ""
        return !tag.isEmpty
    }
    
    func checkValidRecordNumber() -> Bool {
        let number = Double(numberTextField.text!) ?? 0.0
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
    @IBAction func dateSegmentedValueChanged(sender: UISegmentedControl) {
        
        let selectedIndex = dateSegmentedControl.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            let yestoday = NSDate(timeIntervalSinceNow: -secondsOneDay)
            datePicker.date = yestoday
            dateStackView.hidden = true
        case 1:
            let today = NSDate()
            datePicker.date = today
            dateStackView.hidden = true
        default:
            dateStackView.hidden = false
        }
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.contentView.layoutIfNeeded()
            })
    }
    
    // MARK: - Resize and reposition textview for keyboard
    
    func registerForKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        guard let activeView = activeView  else { return }
        
        
        let userInfo = aNotification.userInfo!
        let kbSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        
        if scrollView.contentInset.bottom <= bottomLayoutGuide.length {
            scrollView.contentInset.bottom = bottomLayoutGuide.length + kbSize.height
            scrollView.scrollIndicatorInsets.bottom = bottomLayoutGuide.length + kbSize.height
        }
        
        var visibleRect = scrollView.frame
        visibleRect.size.height -= kbSize.height
        if !CGRectContainsPoint(visibleRect, activeView.frame.origin) {
            scrollView.scrollRectToVisible(activeView.frame, animated: true)
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        if scrollView.contentInset.bottom > bottomLayoutGuide.length {
            scrollView.contentInset.bottom = bottomLayoutGuide.length
            scrollView.scrollIndicatorInsets.bottom = bottomLayoutGuide.length
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testTags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = tagCollectionView.dequeueReusableCellWithReuseIdentifier("TagCollectionViewCell", forIndexPath: indexPath) as! TagCollectionViewCell
        cell.configCell(testTags[indexPath.row])
        return cell
    }
    
    // MARK: Navigatioin
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddRecordMode = presentingViewController is UINavigationController
        if isPresentingInAddRecordMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let tag = tagTextField.text ?? ""
            let number = Double(numberTextField.text!) ?? 0.0
            let date = datePicker.date
            let recordDescription = recordDescriptionTextView.text
            
            record = Record(number: number, tag: tag, date: date, recordDescription: recordDescription)
        }
    }
}

