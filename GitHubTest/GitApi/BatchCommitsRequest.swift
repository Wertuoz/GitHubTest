//
//  BatchCommitsRequest.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 28/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation
import SwiftyJSON

class BatchCommitsRequest {
    
    private let dispatchGroup = DispatchGroup()
    private var token: String = ""
    private var httpMethod: String = ""
    private var responses = [String : Data]()
    private var errors = [String : Error]()
    
    func asyncRequest(urls: [String], token: String, httpMethod: String, completion: @escaping ([String : Data], [String : Error]) -> Void) {
        
        self.token = token
        self.httpMethod = httpMethod
        
        let _ = dispatchGroup.wait(timeout: .distantFuture)

        for url in urls {
            asyncFunctionA(url: url)
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) {
            completion(self.responses, self.errors)
        }
    }

    private func asyncFunctionA(url: String) {
        let apiRequest = ApiRequest(apiNode: "", httpMethod: httpMethod, authToken: token, apiFullUrl: url)
        
        dispatchGroup.enter()
        
        URLSession.shared.dataTask(with: apiRequest.request) { data, response, errorResp in
            do {
                try self.parseResponseForErrors(data: data, response: response, errorResp: errorResp)
                self.responses[url] = data
                self.dispatchGroup.leave()
            } catch {
                self.errors[url] = error
                self.dispatchGroup.leave()
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
}
