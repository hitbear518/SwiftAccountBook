//
//  RecordSectionHeader.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/26.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

protocol RecordSectionHeaderDelegate {
    func openSection(sectionToOpen: Int)
    func closeSection(sectionToClose: Int)
}

class RecordSectionHeader: UITableViewHeaderFooterView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var disclosureButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    var delegate: RecordSectionHeaderDelegate?
    var section: Int!
    
    override func awakeFromNib() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "recordSectionHeaderDidTap:")
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func recordSectionHeaderDidTap(sender: UITapGestureRecognizer) {
        self.disclosureButton.selected = !self.disclosureButton.selected
        
        if self.disclosureButton.selected {
            self.delegate?.openSection(self.section)
        } else {
            self.delegate?.closeSection(self.section)
        }
    }
    
}
