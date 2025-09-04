//
//  Model.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//
import Foundation

// MARK: - Crypto Response для списка криптовалют
struct CryptoResponse: Codable {
    let status: Status
    let data: [CryptoCurrency]
}

// MARK: - Crypto Currency
struct CryptoCurrency: Codable {
    let id: Int
    let name: String
    let symbol: String
    let quote: Quote
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, quote
    }
}

// MARK: - Quote
struct Quote: Codable {
    let usd: USD
    
    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

// MARK: - USD
struct USD: Codable {
    let price: Double
    let percentChange24H: Double
    
    enum CodingKeys: String, CodingKey {
        case price
        case percentChange24H = "percent_change_24h"
    }
}

// MARK: - Status
struct Status: Codable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String?
    let elapsed, creditCount: Int
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
    }
}
