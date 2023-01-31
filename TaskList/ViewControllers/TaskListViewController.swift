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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemGray5
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            StorageManager.shared.delete(task)
        }
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showUpdateAlert(from: task, withTitle: "Update task", withMessage: "What do you want to do?") {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    /// Метод, с помощью которого презентуется AlertController для добавления новой Task
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
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
    
    /// Метод для обновления  введенных пользователем данных по нажатию на кнопку "Update".
    private func update(_ task: Task, taskName: String) {
        StorageManager.shared.update(task, newTask: taskName)
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
    
    /// Метод для создания AlertController при добавлении новой Task
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        present(alert, animated: true)
    }
    
    /// Метод для создания AlertController при обновлении выбранной Task
    private func showUpdateAlert(from task: Task, withTitle title: String, withMessage message: String, completion: () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            update(task, taskName: taskName)
            tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.text = task.title
        }
        
        present(alert, animated: true)
    }
}
