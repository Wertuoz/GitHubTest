//
//  ApiRequest.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 26/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

enum RequestHeaderFields: String {
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case authorization = "Authorization"
    case expect = "Expect"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifRange = "If-Range"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case maxForwards = "Max-Forwards"
    case proxyAuthorization = "Proxy-Authorization"
    case range = "Range"
    case referer = "Referer"
    case te = "TE"
    case userAgent = "User-Agent"
}

enum RequestMethod: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PATCH
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}

enum ApiNode: String {
    case USER = "user"
    case USER_REPOS = "user/repos"
    case USER_COMMITS = "user/commits"
}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}


final class ApiRequest {
    
    private let apiURL: String = "https://api.github.com/"
    
    private var defaultHeaders = [String : String]()
    
    private var authToken: String = ""
    
    private var httpMethod: String = RequestMethod.GET.rawValue
    
    private var apiNode: String
    
    private(set) var request: URLRequest
    
    init(apiNode: String = "", httpMethod: String = "", authToken: String = "", apiFullUrl: String? = nil) {
        self.apiNode = apiNode
        self.httpMethod = httpMethod
        self.authToken = authToken
        
        let authHeader = [RequestHeaderFields.authorization.rawValue : "Basic \(authToken)"]
        defaultHeaders.merge(authHeader) { (oldValue, newValue) -> String in
            return newValue
        }
        
        var url = ""
        if apiFullUrl != nil {
            url = apiFullUrl!.replacingOccurrences(of: "{/sha}", with: "")
        } else {
            url = self.apiURL + self.apiNode
        }
        
        let urlApi = URL(string: url)!
        request = URLRequest(url: urlApi)
        request.httpMethod = self.httpMethod
        for header in defaultHeaders {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
