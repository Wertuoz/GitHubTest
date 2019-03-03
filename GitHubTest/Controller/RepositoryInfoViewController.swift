//
//  RepositoryInfoViewController.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 02/03/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class RepositoryInfoViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var repoNameLbl: UILabel!
    @IBOutlet weak var repoImage: UIImageView!
    @IBOutlet weak var watchersLbl: UILabel!
    @IBOutlet weak var forksLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var commitsTable: UITableView!
    
    var repoId: Int64?
    var repoItem: Repository?
    var repoCommits = [Commit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        commitsTable.dataSource = self
        
        if repoId != nil {
            loadData()
        }
    }
    
    private func loadData() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let dbContext = delegate.persistentContainer.viewContext
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        let predicate = NSPredicate(format: "id = %d", repoId!)
        request.predicate = predicate
        do {
            repoItem = try dbContext.fetch(request).first
            guard let repoCommitsTemp = repoItem?.commits?.allObjects as? [Commit] else {
                return
            }
            repoCommits = repoCommitsTemp
            updateUI()
        } catch {
            print("error")
        }
    }
    
    private func loadImage() {
        guard let strUrl = repoItem?.ownerAvatarUrl else {
            return
        }
        guard let url = URL(string: strUrl) else {
            return
        }
        
        repoImage.kf.indicatorType = .activity
        repoImage.kf.setImage(with: url)
    }
    
    private func updateUI() {
        loadImage()
        updateCommitsTable()
        updateDescription()
        updateWatchersAndForks()
        updateRepoName()
    }
    
    private func updateRepoName() {
        repoNameLbl.text = repoItem?.name ?? ""
    }
    
    private func updateCommitsTable() {
        commitsTable.reloadData()
    }
    
    private func updateDescription() {
        descriptionLbl.text = repoItem?.repoDescription ?? ""
    }
    
    private func updateWatchersAndForks() {
        let forksCount = repoItem?.forksCount ?? 0
        let watchers = repoItem?.watchersCount ?? 0
        forksLbl.text = "Forks: \(forksCount)"
        watchersLbl.text = "Watchers: \(watchers)"
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let parentVC = viewController as? UserPageViewController {
            parentVC.backFromRepo = true
        }
    }
    
    deinit {
        print("deinit")
    }
}

extension RepositoryInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoCommits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commit = repoCommits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath) as! CommitCellTableViewCell
        cell.updateView(hash: commit.commitHash, message: commit.message, commiter: commit.authorName, date: commit.commitDate)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Commits:"
    }
}
