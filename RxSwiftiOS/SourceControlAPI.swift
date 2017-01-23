//
//  SourceControlAPI.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 1/22/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import Foundation
import RxSwift

class SourceControlAPI {

    private static let names = ["Joshua", "Keenan", "Alexandra", "Omaya"]
    private static let actions = ["comitted", "pushed", "forked"]
    private static let repos = ["Project AlphaBeta", "Corp website", "Project Synergy", "Singularity"]

    static func updates() -> Observable<[String: Any]> {
        return Observable.create {observer in
            let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
                DispatchQueue.global(qos: .background).async {
                    let json = ["name": names.sample, "action": actions.sample, "repo": repos.sample]
                    observer.onNext(json)
                }
            }
            timer.fire()

            return Disposables.create {
                timer.invalidate()
            }
        }
    }
}

extension Array {
    fileprivate var sample: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
}
