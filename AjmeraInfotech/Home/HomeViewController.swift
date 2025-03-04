//
//  HomeViewController.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import UIKit
import Combine

class HomeViewController: BaseViewController, Alertable, Loadable {
    
    var viewModel: HomeViewModable = HomeViewModel()
    @IBOutlet weak var userNameLabel: UILabel!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToResultModel()
        subscribeToLoaderView()
        viewModel.getUser()
    }
    
    deinit {
        print("HomeViewController is Deint")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func didTapOnLogOutButton(_ sender: Any) {
        UserManager.sharedInstance.currentUser = nil
        self.changeRootViewController(to: SignInBuilder.build())
    }
    
    private func subscribeToResultModel() {
        viewModel.resultModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let userModel):
                    self?.userNameLabel.text = "Welcome \(userModel?.email ?? "")"
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }).store(in: &cancellables)
    }
    
    private func subscribeToLoaderView() {
        viewModel.showLoaderPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.configLoader(state)
            }).store(in: &cancellables)
    }
}
