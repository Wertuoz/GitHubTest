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

class CommitParser: ApiParser {
    
    override func parseData(data: Data) throws -> AnyObject {
        
        let json = try JSON(data: data)
        
        guard let hash = json["sha"].string else {
            print("hash is empty")
            throw NSError(domain: "", code: 228, userInfo: nil)
        }
        
        let commit = Commit(context: dbContext)
        commit.commitHash = hash
        
        if let message = json["commit"]["message"].string {
            commit.message = message
        }
        
        if let authorName = json["commit"]["author"]["name"].string {
            commit.authorName = authorName
        }
        
        if let commitDate = json["commit"]["author"]["date"].string {
            commit.commitDate = commitDate
        }
        print(commit)
        return commit
        
    }
}
