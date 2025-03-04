//
//  SignUpViewModel.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation
import Combine

protocol SignUpViewable {
    var showLoaderPublisher: PassthroughSubject<LoaderState,Never> { get } 
    var isCreateAccountEnabledPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var resultModelPublisher: Published<Result<SignUpResponseModel?,APIClientError>>.Publisher { get }
    
    var fullName: String { get set }
    var emailText: String { get set }
    var passwordText: String { get set }
    var confirmPassword: String { get set }
    var dateOfBirth: String { get set }
    var gender: String { get set }
    
    func getNumberOfComponentInRow() -> Int
    func titleForrowAt(_ index: Int) -> String?
    func didSelectRow(_ index: Int)
    func selectedGender() -> String?
    
    func createUser()
}

class SignUpViewModel: SignUpViewable {
    var showLoaderPublisher = PassthroughSubject<LoaderState,Never>()
    var isCreateAccountEnabledPublisher: Published<Bool>.Publisher { $isSignUpButtonEnable }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    var resultModelPublisher: Published<Result<SignUpResponseModel?,APIClientError>>.Publisher { $resultModel }
    
    private var genderDataSource: [GenderModel] = [GenderModel(title: "Male", isSelected: true),
                                           GenderModel(title: "Female", isSelected: false),
                                           GenderModel(title: "Other", isSelected: false)]
    
    @Published var fullName: String = ""
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: String = ""
    @Published var gender: String = ""
    @Published var resultModel: Result<SignUpResponseModel?,APIClientError> = .success(nil)
    
    @Published private var errorMessage: String? = ""
    @Published private var isUserInfoValid: Bool = false
    @Published private var isPasswordValidationSuccess: Bool = false
    @Published private var isSignUpButtonEnable: Bool = false
    
    
    private var apiService: APIServicable!
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServicable = APIService.shared) {
        self.apiService = apiService
        checkForUserInfoValidation()
        checkForPasswordValidation()
        checkForSignupValidation()
    }
    
    private func checkForUserInfoValidation() {
        Publishers.CombineLatest4($fullName, $emailText, $dateOfBirth, $gender)
            .map { (fullname, email, dateOfBirth, gender)  in
                if fullname.isEmpty || email.isEmpty || dateOfBirth.isEmpty || gender.isEmpty {
                    self.errorMessage = nil
                    return false
                }
                
                if !ValidationManager.shared.isValidName(fullname) {
                    self.errorMessage = "Invalid Name Format"
                    return false
                }
                
                if !ValidationManager.shared.isValidEmail(email) {
                    self.errorMessage = "Invalid Email Format"
                    return false
                }
                
                if !ValidationManager.shared.isAgeGreaterThan18(dateOfBirth) {
                    self.errorMessage = "Invalid Date age should be more then 18"
                    return false
                }
                
                if gender.isEmpty {
                    self.errorMessage = "Please Enter your gender"
                    return false
                }
                
                self.errorMessage = nil
                return true
            }
            .assign(to: &$isUserInfoValid)
    }
    
    private func checkForPasswordValidation() {
        Publishers.CombineLatest($passwordText, $confirmPassword)
            .map { (password, confirmPassword)  in
                if password.isEmpty || confirmPassword.isEmpty {
                    self.errorMessage = nil
                    return false
                }
                
                if !ValidationManager.shared.isSignupPasswordValid(password) {
                    self.errorMessage = "Password must be at least 6 characters with at least one uppercase, one number and one special case."
                    return false
                }
                
                if password != confirmPassword {
                    self.errorMessage = "Your password and confirm password is not matching."
                    return false
                }
                
                self.errorMessage = nil
                return true
            }
            .assign(to: &$isPasswordValidationSuccess)
    }
    
    private func checkForSignupValidation() {
        Publishers.CombineLatest($isUserInfoValid, $isPasswordValidationSuccess)
            .map { (isUserInfoValid, isPasswordValidationSuccess)  in
            return isUserInfoValid && isPasswordValidationSuccess
        }
        .assign(to: &$isSignUpButtonEnable)
    }
}

extension SignUpViewModel {
    func getNumberOfComponentInRow() -> Int {
        return genderDataSource.count
    }
    
    func titleForrowAt(_ index: Int) -> String? {
        return genderDataSource.map({ $0.title })[index]
    }
    
    func didSelectRow(_ index: Int) {
        genderDataSource.forEach({ $0.isSelected = false })
        genderDataSource[index].isSelected = true
    }
    
    func selectedGender() -> String? {
        genderDataSource.first(where: { $0.isSelected })?.title
    }
}

extension SignUpViewModel {
    func createUser() {
        let userRequest = SignUpRequestModel(fullName: fullName, email: emailText, password: passwordText, dateOfBirth: dateOfBirth, gender: gender)
        self.showLoaderPublisher.send(.showLoader)
        let signupPublisher: AnyPublisher<SignUpResponseModel, APIClientError> = apiService.request(requestType: .signUp(userRequest))
        signupPublisher.sink { completion in
            self.showLoaderPublisher.send(.hideLoader)
            switch completion {
            case .finished:
                print("Request Completed")
            case .failure(let error):
                self.resultModel = .failure(error)
            }
        } receiveValue: { model in
            self.resultModel = .success(model)
        }.store(in: &cancellables)
    }
}
