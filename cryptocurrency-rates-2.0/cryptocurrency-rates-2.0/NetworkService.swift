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
    
    
    func fetchData(from url: String?, with complition: @escaping (Crypocurrency) -> Void) {
        guard let url = URL(string: URLS.cryptocurencyapi.rawValue) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, erorr) in
            if let erorr = erorr {
                print(erorr)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let crypocurrency = try JSONDecoder().decode(Crypocurrency.self, from: data)
                print(crypocurrency)
                DispatchQueue.main.async {
                    complition(crypocurrency)
                }
            }  catch let error {
                print(error)
            }
        }.resume()
        
    }
    
}



