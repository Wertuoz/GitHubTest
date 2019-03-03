//
//  UserPageViewController.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 27/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreData

class UserPageViewController: UITableViewController {

    private var loggingOut = false
    var initFromOnboarding = false
    var backFromRepo = false
    var selectedRepoId: Int64?
    var repoItems = [Repository]()
    
    @IBAction func onLogoutBtnClicked(_ sender: Any) {
        logout()
    }
    
    private func logout() {
        ApiManager.shared.logout()
        performSegue(withIdentifier: "Logout", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if backFromRepo {
            initFromOnboarding = false
            loggingOut = false
            backFromRepo = false
            return
        }
        if initFromOnboarding {
            updateUI()
        } else {
            
            showActivityIndicator()
            
            if Reachability.isConnectedToNetwork() {
                ApiManager.shared.makeInitRequest(login: nil, password: nil) { [unowned self] (error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self.logout()
                        }
                        else {
                            self.updateUI()
                        }
                        self.hideActivityIndicator()
                    }
                }
            }
            else {
                updateUI()
                hideActivityIndicator()
            }
        }
        
        initFromOnboarding = false
    }
    
    private func updateUI() {
        prepareData()
    }
    
    private func prepareData() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let dbContext = delegate.persistentContainer.viewContext
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        do {
            let result = try dbContext.fetch(request)
            for data in result {
                repoItems.append(data)
            }
            tableView.reloadData()
        } catch {
            print("error")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if loggingOut {
            self.navigationController?.viewControllers.removeAll()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Logout" {
            loggingOut = true
        }
        if segue.identifier == "ToRepoInfo" {
            guard let destVC = segue.destination as? RepositoryInfoViewController else {
                return
            }
            
            destVC.repoId = selectedRepoId
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        
        cell.textLabel?.text = repoItems[indexPath.row].fullName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repoItem = repoItems[indexPath.row]
        selectedRepoId = repoItem.id
        performSegue(withIdentifier: "ToRepoInfo", sender: self)
    }
    
    deinit {
        print("deinit")
    }
    
}
