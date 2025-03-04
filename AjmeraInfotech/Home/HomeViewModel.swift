//
//  HomeViewModel.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 04/03/25.
//

import Foundation
import Combine

protocol HomeViewModable {
    func getUser()
    
    var showLoaderPublisher: PassthroughSubject<LoaderState,Never> { get }
    var resultModelPublisher: Published<Result<UserModel?,APIClientError>>.Publisher { get }
}

class HomeViewModel: HomeViewModable {
    var resultModelPublisher: Published<Result<UserModel?,APIClientError>>.Publisher { $resultModel }
    var showLoaderPublisher = PassthroughSubject<LoaderState,Never>()
    
    @Published var resultModel: Result<UserModel?,APIClientError> = .success(nil)
    private var cancellables = Set<AnyCancellable>()
    
    private var apiService: APIServicable!
    
    init(apiService: APIServicable = APIService.shared) {
        self.apiService = apiService
    }
    
    func getUser() {
        let getUserPublisher: AnyPublisher<UserModel, APIClientError> = apiService.request(requestType: .getUser)
        showLoaderPublisher.send(.showLoader)
        getUserPublisher.sink { completion in
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
