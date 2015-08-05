//
//  Account.swift
//  testing
//
//  Created by Camron Godbout on 2/24/15.
//  Copyright (c) 2015 Camron Godbout. All rights reserved.
//

import Foundation
import CoreData

class Account: NSManagedObject {

    @NSManaged var apikey: String
    @NSManaged var username: String
    @NSManaged var password: String

}
