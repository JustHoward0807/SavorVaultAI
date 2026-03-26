//
//  AddDrinkViewController+Navigation.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController {

    /// Sets up the navigation bar actions for the add flow.
    func configureNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .prominent,
            target: self,
            action: #selector(didTapSave)
        )
    }

    /// Dismisses the add drink screen.
    @objc func didTapSave() {
        dismiss(animated: true)
    }
}
