//
//  BaseTestClass.swift
//  RunItTests
//
//  Created by Àlex G. Luque on 17/7/22.
//

import CoreData
import XCTest
@testable import RunIt

class BaseTestClass: XCTestCase {
    
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

        override func setUpWithError() throws {
            dataController = DataController(inMemory: true)
            managedObjectContext = dataController.container.viewContext
        }

}
