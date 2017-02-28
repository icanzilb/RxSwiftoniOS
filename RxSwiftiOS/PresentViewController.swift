//
//  PresentViewController.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 1/21/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let initialRepos = [
    Repo(1, "EasyAnimation", "Swift"),
    Repo(2, "Unbox", "Swift"),
    Repo(3, "RxSwift", "Swift")
]

class PresentViewController: UITableViewController {

    private let repos = Variable<[Repo]>(initialRepos)
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        bindUI()
    }

    func bindUI() {
        // display data
        repos.asObservable()
            .bindTo(tableView.rx.items) { (tableView, row, repo) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel!.text = repo.name
                cell.detailTextLabel?.text = repo.language
                return cell
            }
            .addDisposableTo(bag)

        // present view controller, observe output
        navigationItem.rightBarButtonItem!.rx.tap
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .flatMapFirst {[weak self] _ -> Observable<Repo> in
                if let addVC = self?.storyboard?.instantiateViewController(withIdentifier: "NewRepoViewController") as? NewRepoViewController {
                    self?.navigationController?.pushViewController(addVC, animated: true)
                    return addVC.repoObservable
                }
                return Observable.never()
            }
            .subscribe(onNext: {[weak self] repo in
                self?.repos.value.append(repo)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(bag)
    }
    
}
