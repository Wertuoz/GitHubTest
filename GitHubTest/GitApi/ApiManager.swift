//
//  ApiManager.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 27/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON
import CoreData

enum ApiError: String {
    case badCredentials = "Wrong username or password"
    case unknownApiError = "Unknows api error"
    case unknownError = "Unknown error"
    case emptyData = "Empty data received"
    case emptyResponse = "Empty response"
    case badResponseJson = "An error occured while parsing json(bad json)"
    case emptyRepo = "You have an empty repository"
}

class ApiManager {
    
    static let shared = ApiManager()
    
    static let keychainAppName = "GitHubTest"
    static let keychainAuthToken = "authToken"
    
    private lazy var dbContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private lazy var keychain = {
        Keychain(service: ApiManager.keychainAppName)
    }()

    private var authToken: String {
        get {
            return keychain[ApiManager.keychainAuthToken] ?? ""
        }
        set {
            if newValue.count > 0 {
                keychain[ApiManager.keychainAuthToken] = newValue
            }
        }
    }
    
    //its good to use datagroup, but i have no much time%(
    func makeInitRequest(login: String?, password: String?, completionReq: @escaping (Error?) -> Void) {
        
        var token = authToken
        
        if login != nil && password != nil { token = prepareAuthToken(login: login!, password: password!) }
        
        makeUserRequest(token: token) { (userData, userError) in
            if userError != nil {
                completionReq(userError)
                return
            }
            
            if userData != nil {
                self.makeRepositoryRequest(completion: { (repData, repError) in
                    if repError != nil {
                        completionReq(repError)
                        return
                    }
                    
                    if repData != nil {
                        self.removeOldUser()
                        guard let repCollection = self.createInitData(userData: userData!, repData: repData!) else {
                            let error = NSError(domain: "", code: 302, userInfo: [NSLocalizedDescriptionKey: ApiError.emptyRepo.rawValue])
                            completionReq(error)
                            return
                        }
                        
                        let urls = repCollection.compactMap{$0.commitsUrl}

                        let batchRequest = BatchCommitsRequest()
                        batchRequest.asyncRequest(urls: urls, token: self.authToken, httpMethod: RequestMethod.GET.rawValue, completion: { (dataDict, errorsDict) in
                            if errorsDict.count > 0 {
                                completionReq(errorsDict[Array(errorsDict.keys)[0]])
                            } else {
                                self.postInitData(repCollection: repCollection, commits: dataDict)
                                completionReq(nil)
                            }
                        })
                    }
                })
            }
        }
    }
    
    private func createInitData(userData: Data, repData: Data) -> [Repository]? {
        
        guard let userData = createObjectFromData(data: userData, apiNode: .USER) else {
            return nil
        }
        
        guard let repDataCollection = createObjectFromData(data: repData, apiNode: .USER_REPOS) else {
            return nil
        }
        
        guard let user = userData as? User else {
            return nil
        }
        
        guard let repCollection = repDataCollection as? [Repository] else {
            return nil
        }
        
        linkAndSaveInitData(user: user, repositories: repCollection)
        return repCollection
    }
    
   private func postInitData(repCollection: [Repository], commits: [String : Data]) {
        for repo in repCollection {
            if let commitsData = commits[repo.commitsUrl!] {
                if let commitsDataCollection = createObjectFromData(data: commitsData, apiNode: .USER_COMMITS) as? [Commit] {
                    for commit in commitsDataCollection {
                        repo.addToCommits(commit)
                        commit.repository = repo
                    }
                }
            }
        }
        
        do {
            try dbContext.save()
        } catch {
            print(error)
        }
    }
    
    private func linkAndSaveInitData(user: User, repositories: [Repository]) {
        for repo in repositories {
            repo.user = user
            user.addToRepositories(repo)
            print("repoadded")
        }

        do {
            try dbContext.save()
        } catch {
            print("Failed")
            return
        }
    }
    
    private func removeOldUser() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try dbContext.fetch(request)
            for data in result {
                dbContext.delete(data)
            }
        } catch {
            print("Failed")
            return
        }
        
        do {
            try dbContext.save()
        } catch {
            print("Failed")
            return
        }
    }
    
    private func createObjectFromData(data: Data, apiNode: ApiNode) -> AnyObject? {
        let parserClass = ApiParser.getParserByApiNode(node: apiNode)
        let parserInstance = parserClass.init()
        do {
            let parsedResult = try parserInstance.parseData(data: data)
            return parsedResult
        } catch {
            return nil
        }
    }
    
    private func makeUserRequest(token: String, completion: @escaping (Data?, Error?) -> Void) {
        let apiRequest = ApiRequest(apiNode: ApiNode.USER.rawValue, httpMethod: RequestMethod.GET.rawValue, authToken: token)
        
        URLSession.shared.dataTask(with: apiRequest.request) { data, response, errorResp in
            do {
                try self.parseResponseForErrors(data: data, response: response, errorResp: errorResp)
                self.authToken = token
                completion(data, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private func makeRepositoryRequest(completion: @escaping (Data?, Error?) -> Void) {

        let apiRequest = ApiRequest(apiNode: ApiNode.USER_REPOS.rawValue, httpMethod: RequestMethod.GET.rawValue, authToken: authToken)
        
        URLSession.shared.dataTask(with: apiRequest.request) { data, response, errorResp in
            do {
                try self.parseResponseForErrors(data: data, response: response, errorResp: errorResp)
                print("OK")
                completion(data, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    private func parseResponseForErrors(data: Data?, response: URLResponse?, errorResp: Error?) throws {
        
        if let _ = errorResp {
            throw NSError(domain: "", code: 301, userInfo: [ NSLocalizedDescriptionKey: ApiError.unknownError.rawValue])
        }
        guard let responseLocal = response else {
            throw NSError(domain: "", code: 302, userInfo: [NSLocalizedDescriptionKey: ApiError.emptyResponse.rawValue])
        }
        guard let dataToParse = data else {
            throw NSError(domain: "", code: 304, userInfo: [ NSLocalizedDescriptionKey: ApiError.emptyData.rawValue])
        }
        
        if let httpResponse = responseLocal as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw NSError(domain: "", code: 303, userInfo: [NSLocalizedDescriptionKey: ApiError.badCredentials.rawValue])
            }
            if httpResponse.statusCode < 200 && httpResponse.statusCode >= 300 {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: ApiError.unknownApiError.rawValue])
            }
        }
        
        do {
            let json = try JSON(data: dataToParse)
            print(json)
        } catch {
            throw NSError(domain: "", code: 306, userInfo: [NSLocalizedDescriptionKey: ApiError.badResponseJson.rawValue])
        }
    }
    
    private func prepareAuthToken(login: String, password: String) -> String {
        let authorization = login + ":" + password
        return authorization.toBase64() ?? ""
    }
    
    func logout() {
        keychain[ApiManager.keychainAuthToken] = nil

        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try dbContext.fetch(request)
            for data in result {
                dbContext.delete(data)
            }
            try dbContext.save()
        } catch {
            print("logout error")
            return
        }
    }
}
