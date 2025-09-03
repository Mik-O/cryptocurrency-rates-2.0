//
//  CryptocurrencyTableView.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import UIKit

class CryptocurrencyTableViewController: UITableViewController {
    
    // MARK: - Properies
    private let networkService = NetworkService.shared
    private var cryptocurrencies: [Crypocurrency] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        loadData()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        title = "Криптовалюты"
        tableView.register(CryptocurrencyTableViewCell.self, forCellReuseIdentifier: CryptocurrencyTableViewCell.indetifier)
        tableView.estimatedRowHeight = 70
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data loading
    private func loadData() {
        showloadingIndicator()
        
        networkService.fetchData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.refreshControl?.endRefreshing()
                
            }
        }
    }
    
    
}
