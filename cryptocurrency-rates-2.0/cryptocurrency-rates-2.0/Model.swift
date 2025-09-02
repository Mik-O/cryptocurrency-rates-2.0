//
//  Model.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import Foundation

// MARK: - Crypocurrency
struct Crypocurrency: Codable {
    let data: DataClass
    let status: Status
}

// MARK: - DataClass
struct DataClass: Codable {
    let symbol, id, name: String
    let amount: Int
    let lastUpdated: String
    let quote: [String: Quote]

    enum CodingKeys: String, CodingKey {
        case symbol, id, name, amount
        case lastUpdated = "last_updated"
        case quote
    }
}

// MARK: - Quote
struct Quote: Codable {
    let price: Double
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case price
        case lastUpdated = "last_updated"
    }
}

// MARK: - Status
struct Status: Codable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String
    let elapsed, creditCount: Int
    let notice: String

    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case elapsed
        case creditCount = "credit_count"
        case notice
    }
}

enum URLS: String {
    case cryptocurencyapi = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/category"

}
