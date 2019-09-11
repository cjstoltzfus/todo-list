//
//  TodoItemsViewController.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import UIKit

public protocol ViewModel {
    var title: String { get }
    var createPromptTitle: String { get }
    var itemsCount: Int { get }
    var tableView: UITableView? { get set }

    func refreshData()
    func createNewItem(name: String) throws -> Int
    func editItem(atIndex: Int, name: String) throws
    func deleteItem(atIndex: Int) throws
    func configure(cell: UITableViewCell, atIndex: Int)
    func cellSelected(atIndex: Int, on: UIViewController)
}

public class TodoItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var viewModel: ViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier:SubtitleTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        self.viewModel.tableView = tableView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.refreshData()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        view.backgroundColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addItem))

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc private func addItem() {
        let alert = UIAlertController.textFieldActionItemAlert(title: viewModel.createPromptTitle, textFieldPlaceholder: "Name", actionText: "Create") { name in
            do {
                let index = try self.viewModel.createNewItem(name: name)
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } catch {
                self.present(UIAlertController.errorAlert(), animated: true)
            }
        }

        present(alert, animated: true)
    }

    private func edit(index: Int) {
        let alert = UIAlertController.textFieldActionItemAlert(title: "Edit Name", textFieldPlaceholder: nil, actionText: "Save") { newName in
            do {
                try self.viewModel.editItem(atIndex: index, name: newName)
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } catch {
                self.present(UIAlertController.errorAlert(), animated: true)
            }
        }

        present(alert, animated: true)
    }

    // MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:SubtitleTableViewCell.identifier, for: indexPath)
        viewModel.configure(cell: cell, atIndex: indexPath.row)
        return cell
    }

    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.cellSelected(atIndex: indexPath.row, on: self)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completed) in
            do {
                try self.viewModel.deleteItem(atIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                completed(true)
            } catch {
                completed(false)
            }
        }

        let edit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completed) in
            self.edit(index: indexPath.row)
            completed(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}
