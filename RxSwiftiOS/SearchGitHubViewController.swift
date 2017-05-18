//
//  ViewController.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 1/21/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import UIKit
import Unbox

import RxSwift
import RxCocoa

class SearchGitHubViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    private let bag = DisposeBag()
    private let repos = Variable<[Repo]>([])

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    func bindUI() {
        // observe text, form request, bind table view to result
        searchBar.rx.text
            .orEmpty
            .filter { query in
                return query.characters.count > 2
            }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map { query in
                var apiUrl = URLComponents(string: "https://api.github.com/search/repositories")!
                apiUrl.queryItems = [URLQueryItem(name: "q", value: query)]
                return URLRequest(url: apiUrl.url!)
            }
            .flatMapLatest { request in
                return URLSession.shared.rx.json(request: request)
                    .catchErrorJustReturn([])
            }
            .map { json -> [Repo] in
                guard let json = json as? [String: Any],
                    let items = json["items"] as? [[String: Any]]  else {
                        return []
                }
                return items.flatMap(Repo.init)
            }
            .bind(to: tableView.rx.items) { tableView, row, repo in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel!.text = repo.name
                cell.detailTextLabel?.text = repo.language
                return cell
            }
            .addDisposableTo(bag)
    }
}
