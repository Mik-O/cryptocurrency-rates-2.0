//
//  CryptocurrencyTableView.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import UIKit

class CryptoTableViewController: UITableViewController {
    var cryptocurrencies: [CryptoCurrency] = []
    var deletedCryptoIDs: Set<Int> = []
    let refreshController = UIRefreshControl()
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        setupActivityIndicator()
        loadDeletedCryptoIDs()
        fetchCryptoData()
        
        title = "Криптовалюты"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: "CryptoCell")
        tableView.rowHeight = 70
    }
    
    private func setupRefreshControl() {
        refreshController.addTarget(self, action: #selector(refreshCryptoData), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func loadDeletedCryptoIDs() {
        if let savedIDs = UserDefaults.standard.array(forKey: "deletedCryptoIDs") as? [Int] {
            deletedCryptoIDs = Set(savedIDs)
        }
    }
    
    private func saveDeletedCryptoIDs() {
        UserDefaults.standard.set(Array(deletedCryptoIDs), forKey: "deletedCryptoIDs")
    }
    
    @objc private func refreshCryptoData() {
        fetchCryptoData()
    }
    
    private func fetchCryptoData() {
        activityIndicator.startAnimating()
        
        NetworkManager.shared.fetchCryptoData { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshController.endRefreshing()
                
                switch result {
                case .success(let cryptos):
                    let filteredCryptos = cryptos.filter { crypto in
                        !(self?.deletedCryptoIDs.contains(crypto.id) ?? false)
                    }
                    self?.cryptocurrencies = filteredCryptos
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath) as? CryptoTableViewCell else {
            return UITableViewCell()
        }
        
        let crypto = cryptocurrencies[indexPath.row]
        cell.configure(with: crypto)
        cell.animateAppearance(delay: Double(indexPath.row) * 0.05)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let crypto = cryptocurrencies[indexPath.row]
        
        let detailVC = CryptoDetailViewController()
        detailVC.cryptocurrency = crypto
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromTop
        
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(detailVC, animated: false)
    }
    
    // MARK: - Editing
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cryptoToDelete = cryptocurrencies[indexPath.row]
            
            deletedCryptoIDs.insert(cryptoToDelete.id)
            saveDeletedCryptoIDs()
            
            cryptocurrencies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            showUndoDeleteOption(crypto: cryptoToDelete, at: indexPath)
        }
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: Int) -> Bool {
//        return true
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completion) in
            self?.deleteRow(at: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func deleteRow(at indexPath: IndexPath) {
        let cryptoToDelete = cryptocurrencies[indexPath.row]
        
        deletedCryptoIDs.insert(cryptoToDelete.id)
        saveDeletedCryptoIDs()
        
        cryptocurrencies.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        showUndoDeleteOption(crypto: cryptoToDelete, at: indexPath)
    }
    
    private func showUndoDeleteOption(crypto: CryptoCurrency, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Удалено", message: "\(crypto.name) удалена из списка", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .default) { [weak self] _ in
            self?.deletedCryptoIDs.remove(crypto.id)
            self?.saveDeletedCryptoIDs()
            self?.cryptocurrencies.insert(crypto, at: indexPath.row)
            self?.tableView.insertRows(at: [indexPath], with: .automatic)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(alert, animated: true)
    }
}
