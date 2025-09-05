//
//  CryptoTableViewCell.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 03.09.2025.
//

import UIKit

class CryptoTableViewCell: UITableViewCell {
    // UI элементы
    let cryptoIcon = UIImageView()
    let nameLabel = UILabel()
    let symbolLabel = UILabel()
    let priceLabel = UILabel()
    
    private let textStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Настройка иконки
        cryptoIcon.translatesAutoresizingMaskIntoConstraints = false
        cryptoIcon.contentMode = .scaleAspectFit
        contentView.addSubview(cryptoIcon)
        
        // Настройка текстового стека
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)
        
        // Настройка меток
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        symbolLabel.font = UIFont.systemFont(ofSize: 14)
        symbolLabel.textColor = .gray
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceLabel.textAlignment = .right
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(symbolLabel)
        
        // Настройка ценовой метки
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            cryptoIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cryptoIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cryptoIcon.widthAnchor.constraint(equalToConstant: 36),
            cryptoIcon.heightAnchor.constraint(equalToConstant: 36),
            
            textStack.leadingAnchor.constraint(equalTo: cryptoIcon.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with crypto: CryptoCurrency) {
        nameLabel.text = crypto.name
        symbolLabel.text = crypto.symbol
        
        // Исправленная строка - получаем цену из USD котировки
        if let usdQuote = crypto.quote["USD"] {
            priceLabel.text = formatPrice(usdQuote.price)
        } else {
            priceLabel.text = "N/A"
        }
        
        // Установка иконки в зависимости от символа
        switch crypto.symbol.uppercased() {
        case "BTC":
            cryptoIcon.image = UIImage(systemName: "bitcoin.sign.circle.fill")
            cryptoIcon.tintColor = .systemOrange
        case "ETH":
            cryptoIcon.image = UIImage(systemName: "circle.hexagongrid.fill")
            cryptoIcon.tintColor = .systemBlue
        case "USDT":
            cryptoIcon.image = UIImage(systemName: "dollarsign.circle.fill")
            cryptoIcon.tintColor = .systemGreen
        default:
            cryptoIcon.image = UIImage(systemName: "questionmark.circle.fill")
            cryptoIcon.tintColor = .systemGray
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        if price < 1 {
            return String(format: "$%.4f", price)
        } else {
            return String(format: "$%.2f", price)
        }
    }
}
