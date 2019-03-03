//
//  UserParser.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 27/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class RepositoryParser: ApiParser {
    
    override func parseData(data: Data) throws -> AnyObject {
        
        let json = try JSON(data: data)
        
        guard let repId = json["id"].int64 else {
            print("id is empty")
            throw NSError(domain: "", code: 228, userInfo: nil)
        }
        
        let repo = Repository(context: dbContext)
        repo.id = repId
        
        if let name = json["name"].string {
            repo.name = name
        }
        
        if let fullName = json["full_name"].string {
            repo.fullName = fullName
        }
        
        if let ownerName = json["owner"]["login"].string {
            repo.ownerName = ownerName
        }
        
        if let ownerAvatar = json["owner"]["avatar_url"].string {
            repo.ownerAvatarUrl = ownerAvatar
        }
        
        if let description = json["description"].string {
            repo.repoDescription = description
        }
        
        if let forksCount = json["forks_count"].int32 {
            repo.forksCount = forksCount
        }
        
        if let watchersCount = json["watchers_count"].int32 {
            repo.watchersCount = watchersCount
        }
        
        if let commitsUrl = json["commits_url"].string {
            repo.commitsUrl = commitsUrl
        }
        
        print(repo)
        return repo
        
    }
}
