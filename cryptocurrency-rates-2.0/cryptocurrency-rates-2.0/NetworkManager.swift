//
//  Network Service.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import Foundation
import SystemConfiguration

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case invalidResponse
    case apiKeyMissing
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let apiKey = "f102813e-2db1-4252-8c3d-edd73e8a7752"
    
    private init() {
        print("Инициализация NetworkManager")
        print("API ключ: \(apiKey.prefix(5))...")
    }
    
    func fetchCryptoData(completion: @escaping (Result<[CryptoCurrency], NetworkError>) -> Void) {
        guard isConnectedToNetwork() else {
            print("Нет подключения к интернету")
            completion(.failure(.requestFailed))
            return
        }
        
        if apiKey == "ВАШ_API_КЛЮЧ_ЗДЕСЬ" || apiKey.isEmpty {
            print("ОШИБКА: API ключ не установлен или имеет значение по умолчанию")
            completion(.failure(.apiKeyMissing))
            return
        }
        
        var urlComponents = URLComponents(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest")
        urlComponents?.queryItems = [
            URLQueryItem(name: "start", value: "1"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "convert", value: "USD")
        ]
        
        guard let url = urlComponents?.url else {
            print("ОШИБКА: Не удалось создать URL")
            completion(.failure(.invalidURL))
            return
        }
        
        print("Запрос к URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Неверный ответ сервера")
                completion(.failure(.invalidResponse))
                return
            }
            
            print("Статус код: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("Ошибка HTTP: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Ответ сервера: \(responseString)")
                }
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                print("Нет данных в ответе")
                completion(.failure(.requestFailed))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Ответ API получен, длина: \(responseString.count) символов")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let cryptoResponse = try decoder.decode(CryptoResponse.self, from: data)
                print("Успешно декодировано \(cryptoResponse.data.count) криптовалют")
                completion(.success(cryptoResponse.data))
            } catch {
                print("Ошибка декодирования: \(error)")
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
    
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
