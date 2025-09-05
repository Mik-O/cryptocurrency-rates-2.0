//
//  Model.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//
import Foundation

// Модель для ответа API
struct CryptoResponse: Decodable {
    let data: [CryptoCurrency]
    let status: Status
}

// Модель для статуса ответа
struct Status: Decodable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String?
    let elapsed: Int
    let creditCount: Int
    let notice: String?
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
        case notice
        case totalCount = "total_count"
    }
}

// Модель для криптовалюты
struct CryptoCurrency: Decodable {
    let id: Int
    let name: String
    let symbol: String
    let slug: String
    let numMarketPairs: Int
    let dateAdded: String
    let tags: [String]
    let quote: [String: Quote]
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug, tags, quote
        case numMarketPairs = "num_market_pairs"
        case dateAdded = "date_added"
    }
    
    // Вычисляемое свойство для удобного доступа к цене
    var price: Double {
        return quote["USD"]?.price ?? 0
    }
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    var percentChange24h: Double? {
        return quote["USD"]?.percentChange24h
    }
    
    var marketCap: Double? {
        return quote["USD"]?.marketCap
    }
}

// Модель для котировок
struct Quote: Decodable {
    let price: Double
    let volume24h: Double?
    let percentChange1h: Double?
    let percentChange24h: Double?
    let percentChange7d: Double?
    let marketCap: Double?
    let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case price
        case volume24h = "volume_24h"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
        case marketCap = "market_cap"
        case lastUpdated = "last_updated"
    }
}
