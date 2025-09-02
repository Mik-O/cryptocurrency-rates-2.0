//
//  CryptocurrencyTableView.swift
//  cryptocurrency-rates-2.0
//
//  Created by Таня Кожевникова on 28.08.2025.
//

import UIKit

class CryptocurrencyTableViewController: UITableViewController {
    
    var cryptocurrencies: [Crypocurrency] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        fetchData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cryptocurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cryptocurrency = cryptocurrencies[indexPath.row]
        cell.textLabel?.text = cryptocurrency.data.name
        cell.detailTextLabel?.text = "\(cryptocurrency.data.symbol)"
        
        return cell
    }
    
}

extension CryptocurrencyTableViewController {
    func fetchData() {
        guard let url = URL(string: URLS.cryptocurencyapi.rawValue) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            print(data)
            guard let data = data else { return }
            
            do {
                let cryptocurrencies = try JSONDecoder().decode([Crypocurrency].self, from: data)
                print(cryptocurrencies)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
            
            
        }.resume()
    }
}
