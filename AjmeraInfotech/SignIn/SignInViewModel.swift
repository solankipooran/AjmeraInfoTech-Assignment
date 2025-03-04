//
//  SignInViewModel.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation
import Combine

protocol SignInViewable {
    var showLoaderPublisher: PassthroughSubject<LoaderState,Never> { get }
    var isSignInEnabledPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var resultModelPublisher: Published<Result<SignInResponseModel?,APIClientError>>.Publisher { get }
    
    var emailText: String { get set }
    var passwordText: String { get set }
    
    func logInUser()
}

class SignInViewModel: SignInViewable {
    var showLoaderPublisher = PassthroughSubject<LoaderState,Never>()
    var isSignInEnabledPublisher: Published<Bool>.Publisher { $isSignInEnabled }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }
    var resultModelPublisher: Published<Result<SignInResponseModel?,APIClientError>>.Publisher { $resultModel }
    
    @Published var emailText: String = ""
    @Published var passwordText: String = ""
    
    @Published var resultModel: Result<SignInResponseModel?,APIClientError> = .success(nil)
    @Published private var errorMessage: String? = ""
    @Published private var isSignInEnabled: Bool = false
    
    private var apiService: APIServicable!
    
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: APIServicable = APIService.shared) {
        self.apiService = apiService
        checkForValidation()
    }
    
    private func checkForValidation() {
        Publishers.CombineLatest($emailText, $passwordText)
            .map { [weak self] (email, password) in
                guard let self = self else { return false }
                
                if email.isEmpty || password.isEmpty {
                    self.errorMessage = nil
                    return false
                }
                
                if !ValidationManager.shared.isValidEmail(email) {
                    self.errorMessage = "Invalid Email Format"
                    return false
                }
                
                if !ValidationManager.shared.isValidPassword(password) {
                    self.errorMessage = "Password must be at least 6 characters"
                    return false
                }
                
                self.errorMessage = nil
                return true
            }
            .assign(to: &$isSignInEnabled)
    }
}

extension SignInViewModel {
    func logInUser() {
        let request = SignInRequestModel(email: emailText, password: passwordText)
        showLoaderPublisher.send(.showLoader)
        let loginPublisher: AnyPublisher<SignInResponseModel, APIClientError> = apiService.request(requestType: .signIn(request))
        loginPublisher.sink { completion in
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
