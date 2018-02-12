//
//  ServicesVC.swift
//  ServiceMonitor
//
//  Created by Niklas Nilsson on 2018-02-09.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//


import UIKit


class ServicesVC: UIViewController {
    
    var serviceStatuses: [ServiceStatus]!
    private let urlPinger: URLPinger! = URLPinger.shared
    
    private let servicePingInterval: Double = 5
    private let cellIdentifier = "cellIdentifier"
    private var timer: Timer!
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(ServiceStatusCell.self, forCellReuseIdentifier: cellIdentifier)
        tv.dataSource = self
        tv.rowHeight = 100
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.allowsSelection = false
        return tv
    }()
    
    private lazy var buttonTableViewEdit: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(buttonEditPressed))
    private lazy var buttonTableViewAdd: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add , target: self, action: #selector(buttonAddPressed))

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
        navigationItem.title = "Services"
        navigationItem.leftBarButtonItem = self.buttonTableViewEdit
        navigationItem.rightBarButtonItem = self.buttonTableViewAdd
    }
    
    private func createUrlCheckerTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: servicePingInterval, target: self, selector: #selector(checkServiceStatuses), userInfo: nil, repeats: true)
    }
    
    @objc private func buttonEditPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        self.buttonTableViewEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @objc private func buttonAddPressed() {
        let simpleInputVC = AddServiceVC()
        simpleInputVC.delegate = self
        let navVC = UINavigationController(rootViewController: simpleInputVC)
        navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    private func addServices(services: [ServiceStatus]) {
        tableView.beginUpdates()
        serviceStatuses = serviceStatuses + services
        let currentLastIndex = serviceStatuses.count - 1
        let insertRows = (currentLastIndex ..< currentLastIndex + services.count)
        let insertRowIndices = insertRows.map { IndexPath(item: $0, section: 0) }
        tableView.insertRows(at: insertRowIndices, with: .none)
        tableView.endUpdates()
        StorageHelper.store(object: serviceStatuses, directory: .documents, fileName: ServiceStatus.archivePath)
    }
    
    @objc private func checkServiceStatuses() {
        let uniqueURLs = Set( serviceStatuses.map { $0.url } )
        uniqueURLs.forEach { checkUrl(url: $0) }
    }
    
    private func checkUrl(url: URL) {
        urlPinger.checkUrl(url: url, completion: { [weak self] statusCode in
            DispatchQueue.main.async {
                self?.gotStatus(withUrl: url, statusCode: statusCode)
            }
        })
    }
    
    private func gotStatus(withUrl url: URL, statusCode: Int?) {
        let matchingIndices = self.serviceStatuses.enumerated().filter { $0.element.url == url }.map { $0.offset }
        matchingIndices.forEach {
            self.serviceStatuses[$0].lastChecked = Date()
            self.serviceStatuses[$0].statusCode = statusCode
            if let cell = tableView.cellForRow(at: IndexPath(item: $0, section: 0)) as? ServiceStatusCell {
                self.updateCell(cell: cell, withSiteData: self.serviceStatuses[$0])
            }
        }
    }
    
    private func updateCell(cell: ServiceStatusCell, withSiteData site: ServiceStatus) {
        cell.titleLabel.text = site.name
        cell.subtitleLabel.text = site.url.absoluteString
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
            self.serviceStatuses.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageHelper.store(object: self.serviceStatuses, directory: .documents, fileName: ServiceStatus.archivePath)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ServiceStatusCell
        let site = serviceStatuses[indexPath.item]
        updateCell(cell: cell, withSiteData: site)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceStatuses.count
    }
}

extension ServicesVC: ServiceVCDelegate {
    func serviceStatusSaved(serviceStatus: ServiceStatus){
        addServices(services: [serviceStatus])
        checkUrl(url: serviceStatus.url)
    }
}





