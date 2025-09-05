//
//  Network Service.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "f102813e-2db1-4252-8c3d-edd73e8a7752" // Замените на ваш API-ключ
    private let baseURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"
    
    // Функция для получения данных о криптовалютах
    func fetchCryptoData(limit: Int = 20, completion: @escaping (Result<[CryptoCurrency], Error>) -> Void) {
        // Создаем URL с параметрами
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "start", value: "1"),
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
            
            // Для отладки выведем сырой ответ
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API response: \(jsonString.prefix(500))...") // Выводим первые 500 символов
            }
            
            // Декодируем данные
            do {
                let decoder = JSONDecoder()
                // Убираем автоматическое преобразование ключей, так как у нас есть ручные CodingKeys
                let cryptoResponse = try decoder.decode(CryptoResponse.self, from: data)
                
                // Проверим статус ответа
                if cryptoResponse.status.errorCode != 0 {
                    let errorMessage = cryptoResponse.status.errorMessage ?? "Unknown API error"
                    completion(.failure(NetworkError.apiError(message: errorMessage)))
                    return
                }
                
                completion(.success(cryptoResponse.data))
            } catch {
                print("Decoding error: \(error)")
                print("Error details: \(error.localizedDescription)")
                
                // Детальная информация об ошибке декодирования
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key) in context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: \(type) in context: \(context)")
                    case .valueNotFound(let value, let context):
                        print("Value not found: \(value) in context: \(context)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                
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
    case apiError(message: String)
    
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
        case .apiError(let message):
            return "Ошибка API: \(message)"
        }
    }
}
