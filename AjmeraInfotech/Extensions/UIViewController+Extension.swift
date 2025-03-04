//
//  UIViewController+Extension.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation
import UIKit

extension UIViewController {
    static func instantiate(from storyboardName: String? = nil) -> Self {
        return instantiateFromStoryboard(storyboardName)
    }

    private static func instantiateFromStoryboard<T: UIViewController>(_ storyboardName: String?) -> T {
        let name = storyboardName ?? String(describing: self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: self)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("⚠️ ViewController with identifier \(identifier) not found in \(name) storyboard.")
        }
        return vc
    }
}
