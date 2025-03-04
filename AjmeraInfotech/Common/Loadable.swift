//
//  Loadable.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation
import UIKit

enum LoaderState {
    case showLoader
    case hideLoader
}

protocol Loadable {}
extension Loadable where Self: UIViewController {
    
    private var loaderTag: Int {
        return 10000
    }
    
    func configLoader(_ state: LoaderState) {
        switch state {
        case .showLoader:
            showLoader()
        case .hideLoader:
            hideLoader()
        }
    }
    
    private func showLoader() {
        let loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.color = UIColor.AjmeraColors.orangeFF9044
        loader.startAnimating()
        loader.tag = loaderTag
        view.addSubview(loader)
    }
    
    private func hideLoader() {
        if let loader = view.viewWithTag(loaderTag) as? UIActivityIndicatorView {
            loader.stopAnimating()
            loader.removeFromSuperview()
        }
    }
}
