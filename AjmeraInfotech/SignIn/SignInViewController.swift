//
//  SignInViewController.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import UIKit
import Combine

class SignInViewController: BaseViewController {
    
    var viewModel: SignInViewable!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordProtectionButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldsTargets()
        subcribeToViewModel()
        configureSignInButton(false)
    }
    
    deinit {
        print("SignInViewController is Deint")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Sign In"
        self.emailTextField.becomeFirstResponder()
    }
    
    private func setupTextFieldsTargets() {
        emailTextField.addTarget(self, action: #selector(didEmailEditingChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didPasswordEditingChange), for: .editingChanged)
    }
    
    private func subcribeToViewModel() {
        subscribeToErrorMessage()
        subscribeToIsSignInEnabled()
        subscribeToLoaderView()
        subscribeToResultModel()
    }
    
    @objc private func didEmailEditingChange() {
        viewModel.emailText = emailTextField.text ?? ""
    }
    
    @objc private func didPasswordEditingChange() {
        viewModel.passwordText = passwordTextField.text ?? ""
    }
    
    @IBAction func didTapOnPasswordProtectionButton(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = passwordProtectionButton.isSelected
        passwordProtectionButton.isSelected.toggle()
    }
    
    @IBAction func didTapOnSignInButton(_ sender: UIButton) {
        viewModel.logInUser()
    }
    
    @IBAction func didTapOnSignUpButton(_ sender: UIButton) {
        let signUpViewController = SignUpBuilder.build()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension SignInViewController: Loadable, Alertable {
    private func subscribeToErrorMessage() {
        viewModel.errorMessagePublisher.sink { [weak self] error in
            self?.errorMessageLabel.text = error
        }.store(in: &cancellables)
    }
    
    private func subscribeToIsSignInEnabled() {
        viewModel.isSignInEnabledPublisher.sink { [weak self] isEnabled in
            guard let self else {
                return
            }
            configureSignInButton(isEnabled)
        }.store(in: &cancellables)
    }
    
    private func subscribeToLoaderView() {
        viewModel.showLoaderPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.configLoader(state)
            }).store(in: &cancellables)
    }
    
    private func subscribeToResultModel() {
        viewModel.resultModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let userModel):
                    guard let userModel else {
                        return
                    }
                    UserManager.sharedInstance.currentUser = userModel
                    self?.pushToHomeVC()
                case .failure(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
            }).store(in: &cancellables)
    }
    
    private func configureSignInButton(_ isEnabled: Bool) {
        signInButton.isEnabled = isEnabled
        signInButton.backgroundColor = isEnabled ? UIColor.AjmeraColors.orangeFF9044 : UIColor.AjmeraColors.greyF8F8F8
        signInButton.titleLabel?.textColor = isEnabled ? UIColor.AjmeraColors.white : UIColor.AjmeraColors.black
    }
    
    private func pushToHomeVC() {
        let homeVC = HomeBuilder.build()
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}
