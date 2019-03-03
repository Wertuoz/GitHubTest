//
//  ApiParser.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 27/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import CoreData

protocol Parser {
    func parseData(data: Data) throws -> AnyObject
}

class ApiParser: Parser {
    
    lazy var dbContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func parseData(data: Data) throws -> AnyObject {
        return NSManagedObject(context: dbContext)
    }
    
    static func getParserByApiNode(node: ApiNode) -> ApiParser.Type  {
        switch node {
            case .USER:
                return UserParser.self
            case .USER_REPOS:
                return RepositoryCollectionParser.self
            case .USER_COMMITS:
                return CommitCollectionParser.self
        }
    }
    
    required init() {
    }
}
