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

class RepositoryCollectionParser: ApiParser {
    
    override func parseData(data: Data) throws -> AnyObject {
        
        var parserItems = [Repository]()
        let json = try JSON(data: data)
        let itemParser = RepositoryParser()
        for item in json {
            do {
                let itemData = try item.1.rawData()
                let itemObject = try itemParser.parseData(data: itemData)
                guard let repItem = itemObject as? Repository else {
                    throw NSError(domain: "", code: 198, userInfo: [ NSLocalizedDescriptionKey: "Cant parse repository item"])
                }
                parserItems.append(repItem)
                
            } catch {
                throw NSError(domain: "", code: 199, userInfo: [ NSLocalizedDescriptionKey: "Cant parse repository item"])
            }
        }
        return parserItems as AnyObject
    }
}
