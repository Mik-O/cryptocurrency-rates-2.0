//
//  CryptoTableViewCell.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 03.09.2025.
//

import UIKit

class CryptoTableViewCell: UITableViewCell {
    let cryptoIcon = UIImageView()
    let nameLabel = UILabel()
    let symbolLabel = UILabel()
    let priceLabel = UILabel()
    
    private let textStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        cryptoIcon.translatesAutoresizingMaskIntoConstraints = false
        cryptoIcon.contentMode = .scaleAspectFit
        contentView.addSubview(cryptoIcon)
        
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textStack)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        symbolLabel.font = UIFont.systemFont(ofSize: 14)
        symbolLabel.textColor = .gray
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceLabel.textAlignment = .right
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(symbolLabel)
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func setupAnimations() {
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: 20)
    }
    
    func animateAppearance(delay: Double) {
        UIView.animate(
            withDuration: 0.5,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                self.alpha = 1
                self.transform = .identity
            }
        )
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
    
    func configure(with crypto: CryptoCurrency) {
        nameLabel.text = crypto.name
        symbolLabel.text = crypto.symbol
        
        if let usdQuote = crypto.quote["USD"] {
            priceLabel.text = formatPrice(usdQuote.price)
        } else {
            priceLabel.text = "N/A"
        }
        
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
