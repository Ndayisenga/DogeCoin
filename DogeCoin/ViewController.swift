//
//  ViewController.swift
//  DogeCoin
//
//  Created by Ndayisenga Jean Claude on 10/05/2021.
//

import UIKit
//UI
//MVVM
//API Call
//Pull Refresh


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(DogeTableViewCell.self,
                       forCellReuseIdentifier: DogeTableViewCell.identifier)
        
        return table
    }()
    private var viewModels = [DogeTableViewCellViewModel]()
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    static let dateFormatter : ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        formatter.timeZone = .current
        return formatter
    }()
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var data: DogeCoinData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DogeCoin"
        fetchData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func fetchData() {
        APICaller.shared.getDogeCoinData { [weak self] result in
            switch result  {
            case .success(let data):
                self?.data = data
                DispatchQueue.main.async {
                    self?.setUpViewModels()
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    private func setUpViewModels() {
        guard let model = data else  {
            return
        }
        guard let date = Self.dateFormatter.date(from: model.date_added) else {
            return
        }
        
        //  Create viewModels
        viewModels = [
            DogeTableViewCellViewModel(
                title: "name",
                value: model.name
            ),
            DogeTableViewCellViewModel(
                title: "Symbol",
                value: model.symbol
            ),
            DogeTableViewCellViewModel(
                title: "Identifier",
                value: String(model.id)
            ),
            DogeTableViewCellViewModel(
                title: "Date Added",
                value: Self.prettyDateFormatter.string(from: date)
            ),
            DogeTableViewCellViewModel(
                title: "Total Supply",
                value: String(model.total_supply)
            ),
        ]
        setUpTable()
    }
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        createTableHeader()
    }
    private func createTableHeader() {
        guard let price = data?.quote["USD"]?.price else {
            return
        }
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        header.clipsToBounds = true
        
        // Image
        
        let imageView = UIImageView(image: UIImage(named: "dogecoin"))
        imageView.contentMode = .scaleAspectFit
        let size: CGFloat = view.frame.size.width/4
        imageView.frame = CGRect(x: (view.frame.size.width-size)/2, y: 10, width: size, height: size)
        header.addSubview(imageView)
        //  Price Label
        let number = NSNumber(value: price)
        let string = Self.formatter.string(from: number)
        let label = UILabel()
        label.text = string
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 42, weight: .medium)
        label.frame = CGRect(x: 10, y: 20+size, width: view.frame.size.width-20, height: 120)
        header.addSubview(label)
        tableView.tableHeaderView = header
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell",
                for: indexPath
       ) as? DogeTableViewCell else {
        fatalError()
       }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }


}

