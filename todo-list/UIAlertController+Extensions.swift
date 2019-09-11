//
//  UIAlertController+Extensions.swift
//  todo-list
//
//  Created by Cole Stoltzfus on 9/10/19.
//  Copyright © 2019 Cole Stoltzfus. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func errorAlert() -> UIAlertController {
        let controller = UIAlertController(title: "Whoops", message: "Something went wrong, please try again.", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        return controller
    }

    static func textFieldActionItemAlert(title: String, textFieldPlaceholder: String?, actionText: String, action: @escaping (String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        var cachedTextField: UITextField?
        alert.addTextField() { textField in
            cachedTextField = textField
            textField.placeholder = textFieldPlaceholder
        }
        alert.addAction(UIAlertAction(title: actionText, style: .default) { _ in
            guard let text = cachedTextField?.text else { return }
            action(text)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }
}
