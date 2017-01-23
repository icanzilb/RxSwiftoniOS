//
//  Update.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 1/22/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Update: Object {

    // data properties
    dynamic var id = UUID().uuidString
    dynamic var date = Date()

    dynamic var name = ""
    dynamic var action = ""
    dynamic var repo = ""

    var ago: String {
        return formatter.string(from: date)
    }

    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .long
        f.doesRelativeDateFormatting = true
        return f
    }()

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(object: Any) -> Update? {
        guard let data = object as? [String: Any],
            let name = data["name"] as? String,
            let action = data["action"] as? String,
            let repo = data["repo"] as? String else {
                return nil
        }

        let update = Update()
        update.name = name
        update.action = action
        update.repo = repo
        return update
    }

    static func fromOrEmpty(object: Any) -> Update {
        return from(object: object) ?? Update()
    }
}
