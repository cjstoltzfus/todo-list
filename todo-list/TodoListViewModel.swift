//
//  TodoListViewModel.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

public class TodoListViewModel: ViewModel {
    public let title = "To-Do Lists"
    public let createPromptTitle = "Create To-Do List"
    public var itemsCount: Int {
        return todos.count
    }
    public var tableView: UITableView?

    var todos = [CoreTodoList]()
    let service: TodoListService

    public init(service: TodoListService) {
        self.service = service
    }

    public func refreshData() {
        service.getTodos().observe(on: UIScheduler()).on(value: { [weak self] todos in
            self?.todos = todos
            self?.tableView?.reloadData()
        }).start()
    }

    public func createNewItem(name: String) throws -> Int {
        let newTodo = try service.createTodo(name: name)
        todos.append(newTodo)
        return todos.count - 1
    }

    public func editItem(atIndex index: Int, name: String) throws {
        todos[index].name = name
        try service.commit()
    }

    public func deleteItem(atIndex index: Int) throws {
        try self.service.delete(todo: self.todos[index])
        self.todos.remove(at: index)
    }

    public func configure(cell: UITableViewCell, atIndex index: Int) {
        let todo = todos[index]
        let itemsCount = todo.items?.count ?? 0
        cell.textLabel?.text = todo.name
        cell.detailTextLabel?.text = "# of items: \(itemsCount)"
        cell.accessoryType = .disclosureIndicator
    }

    public func cellSelected(atIndex index: Int, on vc: UIViewController) {
        let itemsViewModel = TodoItemViewModel(service: service, list: todos[index])
        let newVc = TodoItemsViewController(viewModel: itemsViewModel)
        vc.navigationController?.pushViewController(newVc, animated: true)
    }
}
