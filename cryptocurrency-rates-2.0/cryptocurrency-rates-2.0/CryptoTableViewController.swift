//
//  CryptocurrencyTableView.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import UIKit

class CryptoTableViewController: UITableViewController {
    
    private var cryptocurrencies: [CryptoCurrency] = []
    private let refreshController = UIRefreshControl()
    
    // Символы криптовалют для загрузки
    private let cryptoSymbols = ["BTC", "ETH", "USDT", "BNB", "XRP", "ADA", "DOGE", "MATIC", "DOT", "LTC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        fetchCryptoData()
    }
    
    private func setupTableView() {
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.identifier)
        tableView.rowHeight = 70
        tableView.refreshControl = refreshController
        refreshController.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    private func setupNavigationBar() {
        title = "Cryptocurrencies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Добавляем кнопку обновления
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc private func refreshData() {
        fetchCryptoData()
    }
    
    private func fetchCryptoData() {
        NetworkManager.shared.fetchCryptoData { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshController.endRefreshing()
                
                switch result {
                case .success(let cryptos):
                    self?.cryptocurrencies = cryptos
                    self?.tableView.reloadData()
                    print("Успешно загружено \(cryptos.count) криптовалют")
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: NetworkError) {
        var errorMessage = ""
        
        switch error {
        case .apiKeyMissing:
            errorMessage = "API key is missing. Please set your CoinMarketCap API key in NetworkManager.swift"
        case .invalidURL:
            errorMessage = "Invalid URL"
        case .requestFailed:
            errorMessage = "Network request failed"
        case .decodingFailed:
            errorMessage = "Failed to decode response"
        case .invalidResponse:
            errorMessage = "Invalid server response"
        }
        
        showError(message: errorMessage)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.identifier, for: indexPath) as? CryptoTableViewCell else {
            return UITableViewCell()
        }
        
        let crypto = cryptocurrencies[indexPath.row]
        cell.configure(with: crypto)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let crypto = cryptocurrencies[indexPath.row]
        let detailVC = CryptoDetailViewController()
        detailVC.cryptoCurrency = crypto // Убедитесь, что это свойство существует
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showDetail(for crypto: CryptoCurrency) {
        let detailVC = CryptoDetailViewController()
        detailVC.cryptoCurrency = crypto
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
