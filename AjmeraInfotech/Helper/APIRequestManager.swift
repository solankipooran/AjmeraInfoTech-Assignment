//
//  APIRequestManager.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation

enum APIRequestType {
    case signIn(SignInRequestModel)
    case signUp(SignUpRequestModel)
    case getUser
    
    var endPoint: String {
        switch self {
        case .signIn:
            "/auth/login"
        case .signUp:
            "/auth/signup"
        case .getUser:
            "/users/me"
        }
    }
    
    var header: [String: String]? {
        var head: [String : String] = [:]
        if let token = UserManager.sharedInstance.userToken {
            head["Authorization"] = "Bearer \(token)"
        }
        return head
    }
    
    var body: Data? {
        switch self {
        case .signIn(let model):
            return try? JSONEncoder().encode(model)
        case .signUp(let model):
            return try? JSONEncoder().encode(model)
        default:
            return nil
        }
    }
    
    var methodType: HTTPMethod {
        switch self {
        case .signIn, .signUp:
            return .post
        case .getUser:
            return .get
        }
    }
}


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
