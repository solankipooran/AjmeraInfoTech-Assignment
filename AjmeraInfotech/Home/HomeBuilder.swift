//
//  HomeBuilder.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation

final class HomeBuilder {
    static func build() -> HomeViewController {
        let viewcontroller = HomeViewController.instantiate(from: "Main")
        return viewcontroller
    }
}
