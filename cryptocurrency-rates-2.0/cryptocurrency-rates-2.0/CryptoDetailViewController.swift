//
//  CryptoDetailViewController.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 04.09.2025.
//

import UIKit

class CryptoDetailViewController: UIViewController {
    var cryptocurrency: CryptoCurrency!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let infoStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        addInfoCards()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = cryptocurrency.name
        
        // Настройка ScrollView и ContentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Настройка InfoStack
        infoStack.axis = .vertical
        infoStack.spacing = 16
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            infoStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func addInfoCards() {
        // Карточка с ID
        let idCard = createInfoCard(title: "ID", value: "\(cryptocurrency.id)")
        infoStack.addArrangedSubview(idCard)
        
        // Карточка с символом
        let symbolCard = createInfoCard(title: "Symbol", value: cryptocurrency.symbol)
        infoStack.addArrangedSubview(symbolCard)
        
        // Карточка с ценой
        if let usdQuote = cryptocurrency.quote["USD"] {
            let priceCard = createInfoCard(title: "Price", value: formatPrice(usdQuote.price))
            infoStack.addArrangedSubview(priceCard)
            
            // Карточка с изменением за 24 часа (если данные доступны)
            if let percentChange24h = usdQuote.percentChange24h {
                let changeCard = createInfoCard(
                    title: "24h Change",
                    value: formatPercentageChange(percentChange24h)
                )
                infoStack.addArrangedSubview(changeCard)
            }
            
            // Карточка с рыночной капитализацией (если данные доступны)
            if let marketCap = usdQuote.marketCap {
                let marketCapCard = createInfoCard(
                    title: "Market Cap",
                    value: formatMarketCap(marketCap)
                )
                infoStack.addArrangedSubview(marketCapCard)
            }
        }
    }
    
    private func createInfoCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textColor = .label
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        
        return card
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price < 1 {
            return String(format: "$%.6f", price)
        } else {
            return String(format: "$%.2f", price)
        }
    }
    
    private func formatPercentageChange(_ change: Double) -> String {
        let sign = change >= 0 ? "+" : ""
        let color: UIColor = change >= 0 ? .systemGreen : .systemRed
        return String(format: "%@%.2f%%", sign, change)
    }
    
    private func formatMarketCap(_ marketCap: Double) -> String {
        if marketCap >= 1_000_000_000 {
            return String(format: "$%.2fB", marketCap / 1_000_000_000)
        } else if marketCap >= 1_000_000 {
            return String(format: "$%.2fM", marketCap / 1_000_000)
        } else {
            return String(format: "$%.0f", marketCap)
        }
    }
}
