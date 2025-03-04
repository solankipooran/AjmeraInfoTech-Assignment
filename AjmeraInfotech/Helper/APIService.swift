//
//  APIService.swift
//  AjmeraInfotech
//
//  Created by Pooran Kumar on 03/03/25.
//

import Foundation
import Combine

protocol APIServicable {
    func request<T: Decodable>(requestType: APIRequestType) -> AnyPublisher<T, APIClientError>
}

class APIService: APIServicable {
    
    static let shared = APIService()
    
    private init() {}
    
    func request<T: Decodable>(requestType: APIRequestType) -> AnyPublisher<T, APIClientError> {
        let url = AppConstants.shared.baseURL.appendingPathComponent(requestType.endPoint)
        var request = URLRequest(url: url)
        request.httpMethod = requestType.methodType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = requestType.header
        
        if let body = requestType.body {
            request.httpBody = body
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse else {
                    throw APIClientError.invalidResponse
                }
                guard (200...299).contains(response.statusCode) else {
                    throw APIClientError.httpError(statusCode: response.statusCode)
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError({ error in
                return APIClientError.unknown(error)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
