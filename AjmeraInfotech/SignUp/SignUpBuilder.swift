//
//  SignUpBuilder.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation
import UIKit

final class SignUpBuilder {
    static func build() -> SignUpViewController {
        let viewModel = SignUpViewModel()
        let viewController = SignUpViewController.instantiate(from: "Main")
        viewController.viewModel = viewModel
        return viewController
    }
}
