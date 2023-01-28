//
//  TaskViewController.swift
//  TaskList
//
//  Created by Денис Васильев on 28.01.2023.
//

import UIKit

class TaskViewController: UIViewController {
    
    // MARK: - Private Properties
    /// Текстовое поле для добавления новой Task.
    /// Свойство lazy (ленивое), так как нам нужно отложить инициализацию - инициализация произойдет только в момент обращения к этому свойству.
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "New Task"
        return textField
    }()
    
    /// Кнопка для сохранения новой Task
    private lazy var saveButton: UIButton = {
        createButton(
            withTitle: "Save Task",
            andColor: UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 194/255),
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
    }()
    
    /// Кнопка для отмены создания новой Task
    private lazy var cancelButton: UIButton = {
        createButton(
            withTitle: "Cancel",
            andColor: UIColor(red: 236/255, green: 104/255, blue: 74/255, alpha: 224/255),
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
    }()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        setupSubviews(taskTextField, saveButton, cancelButton)
        setConstraints()
    }
}

// MARK: - Private Methods
extension TaskViewController {
    /// Метод, позволяющий добавлять элементы интерфейса одной строкой, перечисляя все параметры через запятую
    /// - Parameter subviews: вариативный параметр, принимает через запятую необходимое количество UIView для отображения на экране
    private func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    /// Метод для создания кнопок
    private func createButton(withTitle title: String, andColor color: UIColor, action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: attributes)
        buttonConfiguration.baseBackgroundColor = color
        
        return UIButton(configuration: buttonConfiguration, primaryAction: action)
    }
    
    /// Метод, настраивающий constraints элементов, добавляемых на экран.
    /// Вызывается исключительно после вызова метода, добавляющего элемент на экран.
    private func setConstraints() {
        // contsraints for taskTextField
        taskTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // contsraints for saveButton
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // contsraints for cancelButton
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
