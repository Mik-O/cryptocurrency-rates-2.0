//
//  CryptocurrencyTableView.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import UIKit

class CryptoTableViewController: UITableViewController {
    var cryptocurrencies: [CryptoCurrency] = []
    let refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoCell")
        setupTableView()
        setupRefreshControl()
        fetchCryptoData()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CryptoCell")
        tableView.rowHeight = 70
    }
    
    private func setupRefreshControl() {
        refreshController.addTarget(self, action: #selector(refreshCryptoData), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    @objc private func refreshCryptoData() {
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
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchCryptoData()
        })
        present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath)
        let crypto = cryptocurrencies[indexPath.row]
        
        // Настраиваем ячейку
        cell.textLabel?.text = "\(crypto.name) (\(crypto.symbol))"
        cell.detailTextLabel?.text = crypto.formattedPrice
        cell.detailTextLabel?.textColor = .systemGreen
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let crypto = cryptocurrencies[indexPath.row]
        print("Выбрана криптовалюта: \(crypto.name), цена: \(crypto.formattedPrice)")
    }
}
