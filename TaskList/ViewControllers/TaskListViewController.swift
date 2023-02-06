//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Денис Васильев on 27.01.2023.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // MARK: - Private Properties
    /// Идентификатор ячейки
    private let cellID = "task"
    /// Список задач для отображения на экране
    private var taskList: [Task] = []
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        fetchData()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    // Edit task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Delete task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.delete(task)
        }
    }
}

// MARK: - Private Methods
extension TaskListViewController {
    /// Метод настройки внешнего вида NavigationBar
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    /// Метод для настройки View
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemGray5
    }
    
    /// Метод, с помощью которого презентуется AlertController для добавления новой Task
    @objc private func addNewTask() {
        showAlert()
    }
    
    /// Метод для сохранения введенных пользователем данных по нажатию на кнопку "Save".
    private func save(_ taskName: String) {
        StorageManager.shared.create(taskName) { task in
            taskList.append(task)
            tableView.insertRows(
                at: [IndexPath(row: taskList.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
    
    /// Метод для восстановления данных из базы
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// Метод для обновления  введенных пользователем данных по нажатию на кнопку "Update".
    private func update(_ task: Task, taskName: String) {
        StorageManager.shared.update(task, newTask: taskName)
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    /// Метод для создания AlertController
    /// - Parameters:
    ///   - task: По умолчанию принимает nil. В случае, если в этот параметр передана задача, то значит, что мы находимся в режиме редактрирования. Если этот параметр не будет никак инициализирован, то значит, что мы в режиме добавления.
    ///   - completion: По умолчанию принимает nil. Нужен для обновления интерфейса.
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Update task" : "New Task"
        let alert = UIAlertController.createAlertController(with: title)
        
        alert.action(task: task) { [weak self] taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.update(task, newTask: taskName)
                completion()
            } else {
                self?.save(taskName)
            }
        }
        
        present(alert, animated: true)
    }
}
