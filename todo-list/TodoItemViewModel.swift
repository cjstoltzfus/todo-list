//
//  TodoItemViewModel.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import UIKit

public class TodoItemViewModel: ViewModel {
    public var title: String {
        return list.name ?? ""
    }
    public let createPromptTitle = "Create To-Do List"
    public var itemsCount: Int {
        return items.count
    }
    public var tableView: UITableView? {
        didSet {
            tableView?.allowsSelection = false
        }
    }

    var items = [CoreTodoItem]()
    let list: CoreTodoList
    let service: TodoListService

    public init(service: TodoListService, list: CoreTodoList) {
        self.service = service
        self.list = list
        self.items = list.items?.compactMap { $0 as? CoreTodoItem } ?? []
    }

    public func refreshData() {
        // no-op
    }

    public func createNewItem(name: String) throws -> Int {
        let item = try service.addItem(name: name, toList: list)
        items.append(item)
        return items.count - 1
    }

    public func editItem(atIndex index: Int, name: String) throws {
        items[index].name = name
        try service.commit()
    }

    public func deleteItem(atIndex index: Int) throws {
        try self.service.removeItem(items[index], fromList: list)
        self.items.remove(at: index)
    }

    public func configure(cell: UITableViewCell, atIndex index: Int) {
        cell.textLabel?.text = items[index].name
    }

    public func cellSelected(atIndex index: Int, on: UIViewController) {
        // no-op
    }
}

