//
//  CombineViewController.swift
//  RxSwiftiOS
//
//  Created by Marin Todorov on 5/18/17.
//  Copyright © 2017 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImage {
    static func fromData(data: Data) -> UIImage { return UIImage(data: data)! }
    static let blank: Data = UIImagePNGRepresentation(UIImage(named: "blank")!)!
}

class CombineViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segment: UISegmentedControl!

    private var bag = DisposeBag()
    fileprivate var followers = Variable<[User]>([])
    fileprivate var avatars = Variable<[UIImage]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        didSelectSegment(segment)
    }


    @IBAction func didSelectSegment(_ sender: Any) {
        // reset UI
        bag = DisposeBag()
        followers.value = []
        avatars.value = []
        collectionView.reloadData()

        // fetch followers
        fetchFollowers()
            .bind(to: followers)
            .disposed(by: bag)

        // get an array of image observables
        let fetchedImages = [getAllAtOnce, getAsTheyCome][segment.selectedSegmentIndex]()

        // store images into avatars
        fetchedImages
            .bind(to: avatars)
            .disposed(by: bag)

        // reload collection
        fetchedImages
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)
    }

    private func getAllAtOnce() -> Observable<[UIImage]> {
        // emit .next only when all images have been downloaded
        return followers.asObservable()
            .map { users -> [Observable<Data>] in
                return users.map { user in
                    let request = URLRequest(url: URL(string: user.avatarUrl)!)
                    return URLSession.shared.rx.data(request: request)
                }
            }
            .flatMap(Observable.combineLatest)
            .map { $0.map(UIImage.fromData) }
            .shareReplay(1)
    }

    private func getAsTheyCome() -> Observable<[UIImage]> {
        // emit .next when each of the images comes in
        return followers.asObservable()
            .map { users -> [Observable<Data>] in
                return users.map { user in
                    let request = URLRequest(url: URL(string: user.avatarUrl)!)
                    return URLSession.shared.rx.data(request: request)
                        .startWith(UIImage.blank)
                }
            }
            .flatMap(Observable.combineLatest)
            .map { $0.map(UIImage.fromData) }
            .shareReplay(1)
    }

    private func fetchFollowers() -> Observable<[User]> {
        return Observable.just("https://api.github.com/users/icanzilb/followers")
            .map { url in
                let apiUrl = URLComponents(string: url)!
                return URLRequest(url: apiUrl.url!)
            }
            .flatMapLatest { request in
                return URLSession.shared.rx.json(request: request)
                    .catchErrorJustReturn([])
            }
            .map { json -> [User] in
                guard let users = json as? [JSONObject]  else {
                    return []
                }
                return users.flatMap(User.init)
            }
    }
}

extension CombineViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(followers.value.count) cells")
        return followers.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = followers.value[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! UserCell
        cell.name!.text = user.login
        if self.avatars.value.count > indexPath.row {
            cell.photo.image = self.avatars.value[indexPath.row]
        }
        return cell
    }
}
