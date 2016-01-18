//
//  MyDataController.swift
//  SwiftAccountBook
//
//  Created by 王森 on 15/12/31.
//  Copyright © 2015年 王森. All rights reserved.
//

import UIKit
import CoreData

class MyDataController {
    
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Error loading model url from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from \(modelURL)")
        }
        let psc  = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex - 1]
            
            let storeURL = docURL.URLByAppendingPathComponent("DataModel.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    // MARK: Static reference
    
    private static var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    static var context: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }
    
    static func save() {
        appDelegate.saveContext()
    }
}
