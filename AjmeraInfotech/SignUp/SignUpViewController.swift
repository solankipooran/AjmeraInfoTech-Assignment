//
//  SignUpViewController.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import UIKit
import Combine

class SignUpViewController: BaseViewController {
    
    var viewModel: SignUpViewable!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var passwordProtectionButton: UIButton!
    @IBOutlet weak var confirmPasswordProtectionButton: UIButton!
    
    private let datePicker = UIDatePicker()
    private let genderPicker = UIPickerView()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToViewModel()
        setupTextFieldsTargets()
        createDatePicker()
        setupGenderPicker()
        configureCreateAccountButton(false)
    }
    
    deinit {
        print("SignUpViewController is Deint")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Sign Up"
        self.nameTextField.becomeFirstResponder()
    }
    
    private func subscribeToViewModel() {
        subscribeToResultModel()
        subscribeToErrorMessage()
        subscribeToIsSignInEnabled()
        subscribeToLoaderView()
    }

    private func setupTextFieldsTargets() {
        nameTextField.addTarget(self, action: #selector(didNameEditingChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(didEmailEditingChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didPasswordEditingChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(didConfirmPasswordEditingChange), for: .editingChanged)
        dateOfBirthTextField.addTarget(self, action: #selector(diddateOfBirthEditingChange), for: .editingDidEnd)
        genderTextField.addTarget(self, action: #selector(didGenderEditingChange), for: .editingDidEnd)
    }
    
    private func createDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        dateOfBirthTextField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didDateDoneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        
        dateOfBirthTextField.inputAccessoryView = toolbar
    }
    
    private func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didGenderDoneButtonPressed))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        genderTextField.inputAccessoryView = toolbar
    }

    @objc private func didDateDoneButtonPressed() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        datePicker.maximumDate = Date()
        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    @objc private func didGenderDoneButtonPressed() {
        genderTextField.text = viewModel.selectedGender()
        self.view.endEditing(true)
    }
    
    @IBAction func didTapOnCreateAccount(_ sender: UIButton) {
        viewModel.createUser()
    }
    
    @IBAction func didTapOnPasswordProtectionButton(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = passwordProtectionButton.isSelected
        passwordProtectionButton.isSelected.toggle()
    }
    
    @IBAction func didTapOnConfirmPasswordProtectionButton(_ sender: UIButton) {
        confirmPasswordTextField.isSecureTextEntry = confirmPasswordProtectionButton.isSelected
        confirmPasswordProtectionButton.isSelected.toggle()
    }
}

//MARK: - TextFields Targets & UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    @objc private func didNameEditingChange() {
        viewModel.fullName = nameTextField.text ?? ""
    }
    
    @objc private func didEmailEditingChange() {
        viewModel.emailText = emailTextField.text ?? ""
    }
    
    @objc private func didPasswordEditingChange() {
        viewModel.passwordText = passwordTextField.text ?? ""
    }
    
    @objc private func didConfirmPasswordEditingChange() {
        viewModel.confirmPassword = confirmPasswordTextField.text ?? ""
    }
    
    @objc private func diddateOfBirthEditingChange() {
        viewModel.dateOfBirth = dateOfBirthTextField.text ?? ""
    }
    
    @objc private func didGenderEditingChange() {
        viewModel.gender = genderTextField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

//MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension SignUpViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getNumberOfComponentInRow()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.titleForrowAt(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.didSelectRow(row)
    }
}

extension SignUpViewController: Alertable, Loadable {
    private func subscribeToErrorMessage() {
        viewModel.errorMessagePublisher.sink { [weak self] error in
            self?.errorMessageLabel.text = error
        }.store(in: &cancellables)
    }
    
    private func subscribeToIsSignInEnabled() {
        viewModel.isCreateAccountEnabledPublisher.sink { [weak self] isEnabled in
            guard let self else {
                return
            }
            configureCreateAccountButton(isEnabled)
        }.store(in: &cancellables)
    }
    
    private func subscribeToResultModel() {
        viewModel.resultModelPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let userModel):
                    UserManager.sharedInstance.currentUser = userModel?.data
                    if UserManager.sharedInstance.isUserLoggedIn {
                        self?.changeRootViewController(to: HomeBuilder.build())
                    }
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
    
    private func configureCreateAccountButton(_ isEnabled: Bool) {
        createAccountButton.isEnabled = isEnabled
        createAccountButton.backgroundColor = isEnabled ? UIColor.AjmeraColors.orangeFF9044 : UIColor.AjmeraColors.greyF8F8F8
        createAccountButton.titleLabel?.textColor = isEnabled ? UIColor.AjmeraColors.white : UIColor.AjmeraColors.black
    }
}
