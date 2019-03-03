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

class CommitCollectionParser: ApiParser {
    
    override func parseData(data: Data) throws -> AnyObject {
        
        var parserItems = [Commit]()
        let json = try JSON(data: data)
        let itemParser = CommitParser()
        for item in json {
            do {
                let itemData = try item.1.rawData()
                let itemObject = try itemParser.parseData(data: itemData)
                guard let repItem = itemObject as? Commit else {
                    throw NSError(domain: "", code: 198, userInfo: [ NSLocalizedDescriptionKey: "Cant parse commit item"])
                }
                parserItems.append(repItem)
                
            } catch {
                throw NSError(domain: "", code: 199, userInfo: [ NSLocalizedDescriptionKey: "Cant parse commit item"])
            }
        }
        return parserItems as AnyObject
    }
}
