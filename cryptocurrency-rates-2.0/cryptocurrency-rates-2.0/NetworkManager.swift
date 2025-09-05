//
//  Network Service.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "f102813e-2db1-4252-8c3d-edd73e8a7752" 
    private let baseURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
    
    // Функция для получения данных о криптовалютах
    func fetchCryptoData(limit: Int = 20, completion: @escaping (Result<[CryptoCurrency], Error>) -> Void) {
        // Создаем URL с параметрами
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "convert", value: "USD")
        ]
        
        guard let url = components.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Создаем запрос
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        // Выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ошибок сети
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем HTTP статус
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Декодируем данные
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let cryptoResponse = try decoder.decode(CryptoResponse.self, from: data)
                completion(.success(cryptoResponse.data))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }
        
        task.resume()
    }
}

// Перечисление для ошибок сети
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .invalidResponse:
            return "Неверный ответ от сервера"
        case .httpError(let statusCode):
            return "HTTP ошибка: \(statusCode)"
        case .noData:
            return "Данные не получены"
        case .decodingError:
            return "Ошибка декодирования данных"
        }
    }
}
