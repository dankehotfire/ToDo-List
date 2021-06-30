//
//  ViewController.swift
//  ToDo-List
//
//  Created by Danil Nurgaliev on 12.06.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var coreDataManager = CoreDataManager()
    var todoArray: [Task] = []
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let context = coreDataManager.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            todoArray = try context.fetch(fetchRequest)
        } catch {
            assertionFailure()
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Please add new task", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let tf = alertController.textFields?.first
            guard let newTitleText = tf?.text else { return }
            self.saveTask(withTitle: newTitleText)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }

        alertController.addTextField(configurationHandler: nil)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func saveTask(withTitle title: String) {
        let context = coreDataManager.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }

        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title

        do {
            try context.save()
            todoArray.append(taskObject)
        } catch {
            assertionFailure()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let task = todoArray[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            todoArray.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)

            let context = coreDataManager.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

            if let objects = try? context.fetch(fetchRequest) {
                context.delete(objects[indexPath.row])
            }

            do {
                try context.save()
            } catch {
                assertionFailure()
            }
        }
    }
}
