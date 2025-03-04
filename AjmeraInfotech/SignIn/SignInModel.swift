//
//  SignInModel.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation

struct SignInRequestModel: Encodable {
    let email: String
    let password: String
}

struct SignInResponseModel: Codable {
    var type: String?
    var user: UserModel?
    var token: String?
}

struct UserModel: Codable {
    let id: String?
    let name: String?
    let email: String?
    let gender: String?
    let dob: String?
}
