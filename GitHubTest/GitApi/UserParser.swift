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

class UserParser: ApiParser {
    
    override func parseData(data: Data) throws -> AnyObject {
        
        let json = try JSON(data: data)
        
        guard let userId = json["id"].int64 else {
            print("id is empty")
            throw NSError(domain: "", code: 228, userInfo: nil)
        }
        
        let user = User(context: dbContext)
        user.id = userId

        if let login = json["login"].string {
            user.login = login
        }
        
        if let avatar = json["avatar_url"].string {
            user.avatarUrl = avatar
        }
        print(user)
        return user
        
    }
}
