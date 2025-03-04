//
//  SignInBuilder.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation
import UIKit

final class SignInBuilder {
    static func build() -> SignInViewController {
        let viewModel = SignInViewModel()
        let viewController = SignInViewController.instantiate(from: "Main")
        viewController.viewModel = viewModel
        return viewController
    }
}
