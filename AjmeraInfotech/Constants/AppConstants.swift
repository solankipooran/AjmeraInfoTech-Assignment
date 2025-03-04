//
//  AppConstants.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation

struct AppConstants {
    static var shared = AppConstants()
    var baseURL: URL {
        //https://144m568g-4000.inc1.devtunnels.ms
        return URL(string: "https://mockapi-26o2.onrender.com")!
//        return URL(string: "https://144m568g-4000.inc1.devtunnels.ms")!
    }
}
