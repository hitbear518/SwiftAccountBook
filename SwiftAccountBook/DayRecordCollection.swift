//
//  DayCost.swift
//  SwiftAccountBook
//
//  Created by 王森 on 16/1/1.
//  Copyright © 2016年 王森. All rights reserved.
//

import Foundation
import CoreData


class DayRecordCollection: NSManagedObject {
    
    var paymentSum: Double {
        return self.records.filter({ !$0.isPayment }).reduce(0.0) { sum, record in
            sum + record.number
        }
    }
    
    var incomeSum: Double {
        return self.records.filter({ $0.isPayment }).reduce(0.0) { sum, record in
            sum + record.number
        }
    }
}
