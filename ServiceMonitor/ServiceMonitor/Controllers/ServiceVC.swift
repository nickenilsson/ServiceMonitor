//
//  ServiceVC.swift
//  ServiceMonitor
//
//  Created by Niklas Nilsson on 2018-01-30.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import UIKit


protocol ServiceVCDelegate: class {
    func serviceStatusSaved(serviceStatus: ServiceStatus)
}

class ServiceVC: UIViewController, UITextFieldDelegate {
    weak var delegate: ServiceVCDelegate?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    private let inputFieldName: UITextField = {
        let inputField = UITextField()
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.borderStyle = .roundedRect
        inputField.placeholder = "Service name"
        return inputField
    }()
    
    private let inputFieldUrl: UITextField = {
        let inputField = UITextField()
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.borderStyle = .roundedRect
        inputField.placeholder = "Service url"
        return inputField
    }()
    
    private let buttonSave: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add service", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        buttonSave.addTarget(self, action: #selector(buttonSavePressed), for: .touchUpInside)
        inputFieldName.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        inputFieldUrl.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        stackView.addArrangedSubview(inputFieldName)
        stackView.addArrangedSubview(inputFieldUrl)
        stackView.addArrangedSubview(buttonSave)
        
        navigationItem.title = "Add new services"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(barButtonDonePressed))
    }
    
    @objc func barButtonDonePressed() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldEditingChanged(_ sender: Any) {
        let isField1Filled = (inputFieldUrl.text != nil && inputFieldUrl.text != "")
        let isField2Filled = (inputFieldName.text != nil && inputFieldName.text != "")
        
        buttonSave.isEnabled = isField1Filled && isField2Filled
    }
    
    @objc func buttonSavePressed(_ sender: Any) {
        guard let urlString = inputFieldUrl.text, let url = URL(string: urlString), let name = inputFieldName.text else { return }
        let service = ServiceStatus(name: name, url: url)
        self.delegate?.serviceStatusSaved(serviceStatus: service)
        inputFieldName.text = nil
        inputFieldUrl.text = nil
        
    }
    

    
    
    
}

