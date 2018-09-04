//
//  Category.swift
//  whatToDo
//
//  Created by Biswajit Sarker on 8/31/18.
//  Copyright © 2018 UnHunch. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
