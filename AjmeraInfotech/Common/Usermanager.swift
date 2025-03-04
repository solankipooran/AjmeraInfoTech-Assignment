//
//  Usermanager.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation

class UserManager {
    static let userName = "userName"
    static let userEmail = "userEmail"
    static let userToken = "userToken"
    static let sharedInstance = UserManager()
    
    var currentUser: SignInResponseModel? {
        didSet {
            saveUser()
        }
    }
    
    private func saveUser() {
        self.userName = currentUser?.user?.name
        self.userEmail = currentUser?.user?.email
        self.userToken = currentUser?.token
    }
    
    var userName: String? {
        get {
            if let language =  UserDefaults.standard.object(forKey: UserManager.userName) as? String {
                return language
            }
            return nil
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: UserManager.userName)
        }
    }
    
    var userToken: String? {
        get {
            if let language =  UserDefaults.standard.object(forKey: UserManager.userToken) as? String {
                return language
            }
            return nil
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: UserManager.userToken)
        }
    }
    
    var userEmail: String? {
        get {
            if let language =  UserDefaults.standard.object(forKey: UserManager.userEmail) as? String {
                return language
            }
            return nil
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: UserManager.userEmail)
        }
    }
    
    var isUserLoggedIn: Bool {
        return self.userToken != nil
    }
}
