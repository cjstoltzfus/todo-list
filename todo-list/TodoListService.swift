//
//  TodoListService.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

public class TodoListService {
    public enum TodoError: Swift.Error {
        case failure
    }

    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        self.context = persistentContainer.newBackgroundContext()
    }

    func getTodos() -> SignalProducer<[CoreTodoList], TodoError> {
        return SignalProducer { (observer, _) in
            let fetch = NSFetchRequest<CoreTodoList>(entityName: String(describing: CoreTodoList.self))
            let asyncFetch = NSAsynchronousFetchRequest(fetchRequest: fetch) { result in
                let list = result.finalResult ?? []
                observer.send(value: list)
                observer.sendCompleted()
            }
            self.context.perform {
                do {
                    try self.context.execute(asyncFetch)
                } catch {
                    observer.send(error: .failure)
                }
            }
        }
    }

    func commit() throws {
        try context.save()
    }

    func createTodo(name: String) throws -> CoreTodoList {
        let todo = CoreTodoList(context: context)
        todo.name = name
        try commit()
        return todo
    }

    func delete(todo: CoreTodoList) throws {
        context.delete(todo)
        try commit()
    }

    func addItem(name: String, toList list: CoreTodoList) throws -> CoreTodoItem {
        let item = CoreTodoItem(context: context)
        item.name = name
        list.addToItems(item)
        try commit()
        return item
    }

    func removeItem(_ item: CoreTodoItem, fromList list: CoreTodoList) throws {
        list.removeFromItems(item)
        try commit()
    }
}
