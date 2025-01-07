//
//  StorageManager.swift
//  TaskList
//
//  Created by Anastasya Maximova on 07.01.2025.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    lazy var context = persistentContainer.viewContext
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let fetchData: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()

    private init() {}
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchData(completion: @escaping(Result<[ToDoTask], NSError>) -> Void) {
        do{
            let task = try context.fetch(fetchData)
            completion(.success(task))
        } catch  {
            let error = error as NSError
            completion(.failure(error))
        }
    }
    
    func saveData(withTitle title: String, completion: @escaping(Result<ToDoTask, NSError>) -> Void) {
        guard let entity = NSEntityDescription.entity(forEntityName: "ToDoTask", in: context) else {return}
        let taskObject = ToDoTask(entity: entity, insertInto: context)
        taskObject.title = title
        do{
            try context.save()
            completion(.success(taskObject))
        } catch {
            let error = error as NSError
            completion(.failure(error))
        }
    }
    
    func deleteData(for object: ToDoTask) {
        if let _ = try? context.fetch(fetchData) {
                context.delete(object)
            }
        do{
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateData(for title: String, indexPath: Int) {
        if let fetchResults = try? context.fetch(fetchData) {
            let result = fetchResults[indexPath]
            result.setValue(title, forKey: "title")
            }
            do{
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
