//
//  SimpleInputVC.swift
//  URLChecker
//
//  Created by Niklas Nilsson on 2018-01-30.
//  Copyright © 2018 Niklas Nilsson. All rights reserved.
//

import UIKit


protocol SimpleInputDelegate: class {
    func inputSaved(text: String)
}

class SimpleInputVC: UIViewController {
    weak var delegate: SimpleInputDelegate?

    private let inputField: UITextField = {
        let inputField = UITextField()
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.borderStyle = .roundedRect
        inputField.placeholder = "input service url"
        return inputField
    }()
    
    private let buttonSave: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add service", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        buttonSave.addTarget(self, action: #selector(buttonSavePressed), for: .touchUpInside)
        setupView()
    }
    
    private func setupView(){
        view.backgroundColor = .white
        view.addSubview(inputField)
        inputField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        
        view.addSubview(buttonSave)
        buttonSave.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonSave.topAnchor.constraint(equalTo: inputField.bottomAnchor).isActive = true
        
        navigationItem.title = "Add new services"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(barButtonDonePressed))
    }
    
    @objc func barButtonDonePressed() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonSavePressed(_ sender: Any) {
        if let text = inputField.text {
            delegate?.inputSaved(text: text)
            inputField.text = nil
        }
    }
    
    
    
}

