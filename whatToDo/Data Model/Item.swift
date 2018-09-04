//
//  Item.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/31/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parenCategory = LinkingObjects(fromType: Category.self, property: "items")
}
