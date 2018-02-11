//
//  ServicesVC.swift
//  ServiceMonitor
//
//  Created by Niklas Nilsson on 2018-02-09.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//


import UIKit

class SimpleCell: UITableViewCell {
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel ()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        
        contentView.addSubview(statusLabel)
        statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        statusLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        statusLabel.text = nil
    }
    
}

class ServicesVC: UIViewController {
    
    var sites: [ServiceStatus]!
    
    private let cellIdentifier = "cellIdentifier"
    private var timer: Timer!
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(SimpleCell.self, forCellReuseIdentifier: cellIdentifier)
        tv.dataSource = self
        tv.rowHeight = 70.0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var buttonTableViewEdit: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(buttonEditPressed))
        return button
    }()
    
    private lazy var buttonTableViewAdd: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add , target: self, action: #selector(buttonAddPressed))
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        timer = createUrlCheckerTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc private func appDidBecomeActive(){
        timer.invalidate()
        timer = createUrlCheckerTimer()
    }
    
    @objc private func appWillResignActive() {
        timer.invalidate()
    }

    
    private func setupView() {
        setupNavBar()
        
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupNavBar(){
        navigationItem.title = "URLChecker"
        navigationItem.leftBarButtonItem = self.buttonTableViewEdit
        navigationItem.rightBarButtonItem = self.buttonTableViewAdd
    }
    
    private func createUrlCheckerTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkServiceStatuses), userInfo: nil, repeats: true)
    }
    
    @objc private func buttonEditPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        self.buttonTableViewEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @objc private func buttonAddPressed() {
        let simpleInputVC = SimpleInputVC()
        simpleInputVC.delegate = self
        let navVC = UINavigationController(rootViewController: simpleInputVC)
        navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    private func addUrls(urls: [URL]) {
        tableView.beginUpdates()
        sites = sites + urls.map { ServiceStatus(statusCode: nil, url: $0, lastChecked: nil) }
        tableView.insertRows(at: [IndexPath(item: sites.count - 1, section: 0)], with: .none)
        tableView.endUpdates()
        StorageHelper.store(object: sites, directory: .documents, fileName: ServiceStatus.archivePath)
    }
    
    @objc private func checkServiceStatuses() {
        let uniqueURLs = Set( sites.map { $0.url } )
        uniqueURLs.forEach { checkUrl(url: $0) }
    }
    
    private func checkUrl(url: URL) {
        URLPinger.shared.checkUrl(url: url, completion: { [weak self] statusCode in
            DispatchQueue.main.async {
                self?.updateRows(withUrl: url, statusCode: statusCode)
            }
        })
    }
    
    private func updateRows(withUrl url: URL, statusCode: Int?) {
        let matchingIndices = self.sites.enumerated().filter { $0.element.url == url }.map { $0.offset }
        matchingIndices.forEach {
            self.sites[$0].lastChecked = Date()
            self.sites[$0].statusCode = statusCode
            if let cell = tableView.cellForRow(at: IndexPath(item: $0, section: 0)) as? SimpleCell {
                self.updateCell(cell: cell, withSiteData: self.sites[$0])
            }
        }
    }
    
    private func updateCell(cell: SimpleCell, withSiteData site: ServiceStatus) {
        
        cell.titleLabel.text = site.url.absoluteString
        if let statusDescription = site.statusDescription {
            cell.statusLabel.text = statusDescription
        }
        if let date = site.lastChecked {
            cell.dateLabel.text = "\(date)"
        }
    }
}

extension ServicesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.sites.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageHelper.store(object: self.sites, directory: .documents, fileName: ServiceStatus.archivePath)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SimpleCell
        let site = sites[indexPath.item]
        updateCell(cell: cell, withSiteData: site)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites.count
    }
}

extension ServicesVC: SimpleInputDelegate {
    func inputSaved(text: String) {
        guard let url = URL(string: text) else { return }
        addUrls(urls: [url])
        checkUrl(url: url)
    }
}





