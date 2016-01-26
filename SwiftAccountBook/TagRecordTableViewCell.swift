//
//  TagRecordTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/24.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class TagRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tagSumView: UIView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var recordTag: Tag!
    var sortedRecords: [Record]!
    var isPayment: Bool!
    var opened: Bool!
    var delegate: RecordTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tagRecordsLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "tagSumDidLongPress:")
        tagRecordsLongPressGestureRecognizer.minimumPressDuration = 0.001
        self.tagSumView.addGestureRecognizer(tagRecordsLongPressGestureRecognizer)
        self.tagSumView.layer.cornerRadius = 6.0
        self.tagSumView.clipsToBounds = true
    }
    
    func tagSumDidLongPress(recognizer: UILongPressGestureRecognizer) {
        handleLongPress(recognizer) {
            self.delegate?.sumViewDidTapAtCell(self)
        }
    }
    
    private func handleLongPress(recognizer: UILongPressGestureRecognizer, handler: () -> Void) {
        let view = recognizer.view!
        let location = recognizer.locationInView(view)
        switch recognizer.state {
        case .Began:
            view.backgroundColor = ThemeManager.currentTheme.hightlightColor
        case .Changed:
            if CGRectContainsPoint(view.bounds, location) {
                view.backgroundColor = ThemeManager.currentTheme.hightlightColor
            } else {
                view.backgroundColor = UIColor.clearColor()
            }
        case .Cancelled:
            view.backgroundColor = UIColor.clearColor()
        case .Ended:
            view.backgroundColor = UIColor.clearColor()
            if CGRectContainsPoint(view.bounds, location) {
                handler()
            }
        default:
            break
        }
    }
    
    func configCell(tag: Tag, records: [Record], opened: Bool) {
        self.recordTag = tag
        self.sortedRecords = records.sort { left, right in
            left.date.timeIntervalSinceDate(right.date) > 0
        }
        self.isPayment = tag.ofPayment
        self.opened = opened
        
        for view in stackView.arrangedSubviews {
            if view !== tagSumView {
                view.removeFromSuperview()
            }
        }
        
        setTexts()
        setAppearances()
        
        if opened {
            let separator = NSBundle.mainBundle().loadNibNamed("InCellSeparator", owner: nil, options: nil).first as! UIView
            stackView.addArrangedSubview(separator)
            
            for record in sortedRecords {
                let recordView = loadRecordView(record)
                let recordLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "recordDidLongPress:")
                recordLongPressGestureRecognizer.minimumPressDuration = 0.001
                recordView.addGestureRecognizer(recordLongPressGestureRecognizer)
                stackView.addArrangedSubview(recordView)
            }
        }
    }
    
    private func setTexts() {
        self.tagLabel.text = self.recordTag.name
        let recordsSum = self.sortedRecords.reduce(0.0) { sum, record in
            sum + record.number
        }
        self.sumLabel.text = "\(recordsSum) 元"
    }
    
    private func setAppearances() {
        let tagOpenedImage: UIImage
        if self.isPayment == true {
            tagOpenedImage = UIImage(named: "TagOpenedPayment")!
        } else {
            tagOpenedImage = UIImage(named: "TagOpenedIncome")!
        }
        let tagClosedImage = UIImage(named: "TagClosed")
        let openedBackgroundImage = UIImage(named: "CellBackgroundOpened")!
        let closedBackgroundImage = UIImage(named: "CellBackgroundClosed")!
        
        if self.opened == true {
            self.backgroundImageView.image = openedBackgroundImage
            self.tagImageView.image = tagOpenedImage
            self.tagLabel.textColor = ThemeManager.currentTheme.primaryTextColor
            self.sumLabel.textColor = ThemeManager.currentTheme.primaryTextColor
        } else {
            self.backgroundImageView.image = closedBackgroundImage
            self.tagImageView.image = tagClosedImage
            self.tagLabel.textColor = ThemeManager.currentTheme.secondaryTextColor
            self.sumLabel.textColor = ThemeManager.currentTheme.secondaryTextColor
        }
    }
    
    private func loadRecordView(record: Record) -> RecordView {
        let views = NSBundle.mainBundle().loadNibNamed("RecordView", owner: nil, options: nil)
        let recordView = views.first as! RecordView
        recordView.leftLabel.text = Utils.getDateStr(record.date, dateStyle: .MediumStyle)
        recordView.numberLabel.text = "\(record.number) 元"
        return recordView
    }
    
    func recordDidLongPress(recognizer: UILongPressGestureRecognizer) {
        handleLongPress(recognizer) {
            let index = self.stackView.arrangedSubviews.indexOf(recognizer.view!)!
            self.delegate?.recordDidTap(self.sortedRecords[index - 2])
        }
    }
}
