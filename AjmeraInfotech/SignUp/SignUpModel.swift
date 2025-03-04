//
//  SignUpModel.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation

class SignUpRequestModel: Encodable {
    let fullName: String
    let email: String
    let password: String
    let dateOfBirth: String
    let gender: String
    
    init(fullName: String, email: String, password: String, dateOfBirth: String, gender: String) {
        self.fullName = fullName
        self.email = email
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.gender = gender
    }
}

struct SignUpResponseModel: Decodable {
    let success: Bool
    let message: String
    let isAlreadyExist: Bool = false
    var data: SignInResponseModel?
}

class GenderModel {
    let title: String
    var isSelected: Bool
    
    init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
}
