//
//  CryptoTableViewCell.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 03.09.2025.
//

import UIKit

class CryptoTableViewCell: UITableViewCell {
    static let identifier = "CryptoTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cryptoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "bitcoinsign.circle.fill")
        imageView.tintColor = .systemOrange
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, symbolLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cryptoIcon)
        contentView.addSubview(textStack)
        contentView.addSubview(priceLabel)
        
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
            priceLabel.text = formatPrice(crypto.quote.usd.price)
          
          // Устанавливаем иконку в зависимости от символа
          switch crypto.symbol {
          case "BTC":
              cryptoIcon.image = UIImage(systemName: "bitcoinsign.circle.fill")
              cryptoIcon.tintColor = .systemOrange
          case "ETH":
              cryptoIcon.image = UIImage(systemName: "circle.hexagongrid.fill")
              cryptoIcon.tintColor = .systemBlue
          case "USDT":
              cryptoIcon.image = UIImage(systemName: "dollarsign.circle.fill")
              cryptoIcon.tintColor = .systemGreen
          default:
              cryptoIcon.image = UIImage(systemName: "bitcoinsign.circle.fill")
              cryptoIcon.tintColor = .systemPurple
          }
      }
    
    private func formatPrice(_ price: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = price < 1 ? 6 : 2
            return formatter.string(from: NSNumber(value: price)) ?? "$0.00"
        }
}

