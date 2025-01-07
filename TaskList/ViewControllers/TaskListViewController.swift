//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private var taskList: [ToDoTask] = []
    private let storageManager = StorageManager.shared
    private let cellID = "task"
    private var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            andMessage: "What do you want to do?",
            actionButtonTitle: "OK") {[unowned self] in
                save(text)
            }
    }
    
    private func fetchData() {
        storageManager.fetchData { [weak self] result in
            guard let self else {return}
            switch result {
            case .success(let task):
                taskList = task
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskName: String) {
        storageManager.saveData(withTitle: taskName) { [weak self] result in
            guard let self else {return}
            switch result {
            case .success (let task):
                taskList.append(task)
                let indexPath = IndexPath(row: taskList.count - 1, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        actionButtonTitle: String,
        indexPath: Int? = nil,
        completion: (()-> Void)? = nil
    ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: actionButtonTitle, style: .default) {[unowned self] _ in
            guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
            text = inputText
            completion?()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(actionButton)
        alert.addAction(cancelAction)
        alert.addTextField {[weak self] textField in
            guard let self else {return}
            textField.placeholder = "New Task"
            guard let indexPath = indexPath else {return}
            textField.text = taskList[indexPath].title
        }
        present(alert, animated: true)
        return
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(
            withTitle: "Edit Task",
            andMessage: "What do you want to do?",
            actionButtonTitle: "Save",
            indexPath: indexPath.row
        ) { [unowned self] in
            storageManager.updateData(for: text, indexPath: indexPath.row)
            fetchData()
            tableView.reloadData()
        }
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
     
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            storageManager.deleteData(for: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            }
        }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
