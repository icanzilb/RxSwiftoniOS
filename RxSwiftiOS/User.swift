//
//  User.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 5/18/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]

struct User {
    let id: Int
    let login: String
    let avatarUrl: String

    init?(object: JSONObject) {
        guard let id = object["id"] as? Int,
            let login = object["login"] as? String,
            let avatarUrl = object["avatar_url"] as? String else {
                return nil
        }
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
    }

    init(_ id: Int, _ login: String, _ avatarUrl: String) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
    }
}
