//
//  DayRecordsTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

class DayRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var dateSumView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tagImageView: UIImageView!
    
    var dayRecords: DayRecords!
    var sortedRecords: [Record] {
        dayRecords.records.first?.isPayment
        return dayRecords.records.sort({ (left, right) -> Bool in
            return left.date.timeIntervalSinceDate(right.date) > 0
        }).filter {
            return $0.isPayment == self.isPayment
        }
    }
    
    var opened: Bool!
    var isPayment: Bool!
    var delegate: RecordTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let dayRecordsLongPressGestureRecoginzer = UILongPressGestureRecognizer(target: self, action: "dateSumDidLongPress:")
        dayRecordsLongPressGestureRecoginzer.minimumPressDuration = 0.001
        self.dateSumView.addGestureRecognizer(dayRecordsLongPressGestureRecoginzer)
        self.dateSumView.layer.cornerRadius = 6.0
        self.dateSumView.clipsToBounds = true
    }
    
    func dateSumDidLongPress(recognizer: UILongPressGestureRecognizer) {
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
    
    func configCell(dayRecords: DayRecords, isPayment: Bool, opened: Bool) {
        self.isPayment = isPayment
        self.opened = opened
        self.dayRecords = dayRecords
        
        for view in self.stackView.arrangedSubviews {
            if view !== self.dateSumView {
                view.removeFromSuperview()
            }
        }
        
        setTexts()
        setAppearances()
        
        if self.opened == true {
            let separator = NSBundle.mainBundle().loadNibNamed("InCellSeparator", owner: nil, options: nil).first as! UIView
            self.stackView.addArrangedSubview(separator)
            for record in self.sortedRecords {
                let recordView = loadRecordView(record)
                let recordLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "recordDidLongPress:")
                recordLongPressGestureRecognizer.minimumPressDuration = 0.001
                recordView.addGestureRecognizer(recordLongPressGestureRecognizer)
                self.stackView.addArrangedSubview(recordView)
            }
        }
    }
    
    private func setTexts() {
        dateLabel.text = Utils.getDateStr(dayRecords.date, dateStyle: .MediumStyle)
        if self.isPayment == true {
            self.sumLabel.text = "\(dayRecords.paymentSum) 元"
        } else {
            self.sumLabel.text = "\(dayRecords.incomeSum) 元"
        }
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
            self.dateLabel.textColor = ThemeManager.currentTheme.primaryTextColor
            self.sumLabel.textColor = ThemeManager.currentTheme.primaryTextColor
        } else {
            self.backgroundImageView.image = closedBackgroundImage
            self.tagImageView.image = tagClosedImage
            self.dateLabel.textColor = ThemeManager.currentTheme.secondaryTextColor
            self.sumLabel.textColor = ThemeManager.currentTheme.secondaryTextColor
        }
    }
    
    func recordDidLongPress(recognizer: UILongPressGestureRecognizer) {
        handleLongPress(recognizer) {
            let index = self.stackView.arrangedSubviews.indexOf(recognizer.view!)!
            self.delegate?.recordDidTap(self.sortedRecords[index - 2])
        }
    }
    
    private func loadRecordView(record: Record) -> RecordView {
        let views = NSBundle.mainBundle().loadNibNamed("RecordView", owner: nil, options: nil)
        let recordView = views.first as! RecordView
        recordView.leftLabel.text = Utils.getTrancatedTagsText(record.tags)
        recordView.numberLabel.text = "\(record.number) 元"
        return recordView
    }
}
