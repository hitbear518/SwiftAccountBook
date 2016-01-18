//
//  DayRecordsTableViewCell.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import UIKit

protocol DayRecordCollectionTableViewCellDelegate {
    func dayRecordCollectionDidTapAtCell(cell: DayRecordCollectionTableViewCell)
    func recordDidTap(record: Record)
}

class DayRecordCollectionTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var dayRecordCollectionView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tagImageView: UIImageView!
    
    var dayRecordCollection: DayRecordCollection!
    var sortedRecords: [Record] {
        return dayRecordCollection.records.sort({ (left, right) -> Bool in
            return left.date.timeIntervalSinceDate(right.date) > 0
        })
    }
    var opened = false
    var delegate: DayRecordCollectionTableViewCellDelegate?
    
    let highlightColor = UIColor(red: 0xF8 / 256.0, green: 0xF5 / 256.0, blue: 0xEC / 256.0, alpha: 1.0)
    let closedTextColor = UIColor(red: 0x7A / 256.0, green: 0x78 / 256.0, blue: 0x72 / 256.0, alpha: 1.0)
    let openedBackgroundImage = UIImage(named: "DayRecordCollectionCellOpened")!
    let closedBackgroundImage = UIImage(named: "DayRecordCollectionCellClosed")!
    let tagOpenedImage = UIImage(named: "tag_opened")
    let tagclosedImage = UIImage(named: "tag_closed")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let dayRecordCollectionLongPressGestureRecoginzer = UILongPressGestureRecognizer(target: self, action: "dayRecordCollectionDidLongPress:")
        dayRecordCollectionLongPressGestureRecoginzer.minimumPressDuration = 0.001
        self.dayRecordCollectionView.addGestureRecognizer(dayRecordCollectionLongPressGestureRecoginzer)
        self.dayRecordCollectionView.layer.cornerRadius = 6.0
        self.dayRecordCollectionView.clipsToBounds = true
    }
    
    func configCell(dayRecordCollection: DayRecordCollection, opened: Bool) {
        self.dateLabel.text = NSDateFormatter.localizedStringFromDate(dayRecordCollection.date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        self.sumLabel.text = String(dayRecordCollection.paymentSum)
        self.dayRecordCollection = dayRecordCollection
        
        
        for view in self.stackView.arrangedSubviews {
            if view !== self.dayRecordCollectionView {
                view.removeFromSuperview()
            }
        }
        
        self.opened = opened
        setCorrespondingAppearance(opened)
        if self.opened {
            for record in self.sortedRecords {
                let recordView = loadRecordView(record)
                let recordLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "recordDidLongPress:")
                recordLongPressGestureRecognizer.minimumPressDuration = 0.001
                recordView.addGestureRecognizer(recordLongPressGestureRecognizer)
                self.stackView.addArrangedSubview(recordView)
            }
        }
    }
    
    func dayRecordCollectionDidLongPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case.Began:
            self.dayRecordCollectionView.backgroundColor = self.highlightColor
        case .Changed:
            let location = sender.locationInView(self.dayRecordCollectionView)
            if CGRectContainsPoint(self.dayRecordCollectionView.bounds, location) {
                self.dayRecordCollectionView.backgroundColor = self.highlightColor
            } else {
                self.dayRecordCollectionView.backgroundColor = UIColor.clearColor()
            }
        case .Ended:
            let location = sender.locationInView(self.dayRecordCollectionView)
            if CGRectContainsPoint(self.dayRecordCollectionView.bounds, location) {
                self.dayRecordCollectionView.backgroundColor = UIColor.clearColor()
                self.delegate?.dayRecordCollectionDidTapAtCell(self)
            }
        case .Cancelled:
            self.backgroundColor = UIColor.clearColor()
        default:
            break
        }
    }
    
    private func setCorrespondingAppearance(opened: Bool) {
        if opened {
            self.backgroundImageView.image = self.openedBackgroundImage
            self.tagImageView.image = self.tagOpenedImage
            self.dateLabel.textColor = UIColor.blackColor()
            self.dateLabel.textColor = UIColor.blackColor()
        } else {
            self.backgroundImageView.image = self.closedBackgroundImage
            self.tagImageView.image = self.tagclosedImage
            self.dateLabel.textColor = self.closedTextColor
            self.sumLabel.textColor = self.closedTextColor
        }
    }
    
    func recordDidLongPress(sender: UILongPressGestureRecognizer) {
        let recordView = sender.view!
        let index = self.stackView.arrangedSubviews.indexOf(recordView)!
        switch sender.state {
        case.Began:
            recordView.backgroundColor = self.highlightColor
        case .Changed:
            let location = sender.locationInView(recordView)
            if CGRectContainsPoint(recordView.bounds, location) {
               recordView.backgroundColor = self.highlightColor
            } else {
                recordView.backgroundColor = UIColor.clearColor()
            }
        case .Ended:
            let location = sender.locationInView(recordView)
            if CGRectContainsPoint(recordView.bounds, location) {
                recordView.backgroundColor = UIColor.clearColor()
                self.delegate?.recordDidTap(self.sortedRecords[index - 1])
            }
        case .Cancelled:
            recordView.backgroundColor = UIColor.clearColor()
        default:
            break
        }
        
    }
    
    private func loadRecordView(record: Record) -> RecordView {
        let views = NSBundle.mainBundle().loadNibNamed("RecordView", owner: nil, options: nil)
        let recordView = views.first as! RecordView
        recordView.tagsLabel.text = Utils.getTrancatedTagsText(record.tags)
        
        recordView.numberLabel.text = String(record.number)
        recordView.sizeToFit()
        
        return recordView
    }
    
    private func createRecordView(record: Record) -> UIView {
        
        let recordStack = UIStackView()
        recordStack.distribution = .Fill
        recordStack.alignment = .Center
        recordStack.axis = .Horizontal
        recordStack.spacing = 8
        
        let tagsLabel = UILabel()
        var tagsText = ""
        record.tags?.forEach { tag in
            tagsText = tagsText + tag.name + ", "
        }
        if !tagsText.isEmpty {
            tagsText = tagsText.substringToIndex(tagsText.endIndex.advancedBy(-2))
        } else {
            tagsText = "无标签"
        }
        tagsLabel.text = tagsText
        tagsLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow - 1, forAxis: .Horizontal)
        tagsLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow - 1, forAxis: .Horizontal)

        let numberLabel = UILabel()
        numberLabel.text = String(record.number)
        
        recordStack.addArrangedSubview(tagsLabel)
        recordStack.addArrangedSubview(numberLabel)
        
        return recordStack
    }
}
