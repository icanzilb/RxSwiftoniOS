//
//  NewRepoViewController.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 1/21/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class NewRepoViewController: UITableViewController {

    @IBOutlet var id: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var language: UITextField!
    @IBOutlet var saveButton: UIButton!

    private let bag = DisposeBag()
    private let repo = PublishSubject<Repo>()

    lazy var repoObservable: Observable<Repo> = {
        return self.repo.asObservable()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    func bindUI() {
        // current repo data
        let currentRepo = Observable.combineLatest(id.rx.text, name.rx.text, language.rx.text) { id, name, lang -> Repo? in
                guard let id = id, let idInt = Int(id),
                    let name = name, name.characters.count > 1,
                    let lang = lang, lang.characters.count > 0 else {
                        return nil
                }
                return Repo(idInt, name, lang)
            }
            .shareReplay(1)

        // toggle save button
        currentRepo
            .map { $0 != nil }
            .bindTo(saveButton.rx.isEnabled)
            .addDisposableTo(bag)

        // emit repo when saved
        saveButton.rx.tap
            .withLatestFrom(currentRepo)
            .subscribe(onNext: {[weak self] repo in
                if let repo = repo {
                    self?.repo.onNext(repo)
                    self?.repo.onCompleted()
                }
            })
            .addDisposableTo(bag)
    }
}
