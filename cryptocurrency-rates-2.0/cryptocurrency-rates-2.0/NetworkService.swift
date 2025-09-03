//
//  Network Service.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    private let apiKey = "f102813e-2db1-4252-8c3d-edd73e8a7752"
    private let baseURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
    
    
    func fetchData(from url: String?, with complition: @escaping (Crypocurrency) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO-API-KEY")
        request.httpMethod = "GET"
        
        let parameters: [String: String] = [
            "start" : "1",
            "limit" : "10",
            "convert" : "USD"
        ]
        
        request.url = URL(string: baseURL + "?" + parameters.map { "\($0) = \($1)" }.joined(separator: "&"))
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do  {
                let coder = JSONDecoder()
                _ = try coder.decode(Crypocurrency.self, from: data)
            } catch {
                print("Decoding error: \(error)")
            }
            
        }.resume()
        
    }
    
}

