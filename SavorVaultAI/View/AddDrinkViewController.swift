//
//  AddDrinkViewController.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/23/26.
//

import UIKit

class AddDrinkViewController: UIViewController {

    var selectedDrinkType: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedDrinkType ?? "Add Drink"
        configureNavigationItems()
    }

    private func configureNavigationItems() {
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

    @objc private func didTapSave() {
        dismiss(animated: true)
    }
}
