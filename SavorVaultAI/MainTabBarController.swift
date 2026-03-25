//
//  MainTabBarController.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/23/26.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private enum TabIndex {
        static let add = 3
    }

    private enum StoryboardScene {
        static let addDrinkViewController = "AddDrinkViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        installAddActionTabIfNeeded()
        configureTabBarItems()
    }

    private func configureTabBarItems() {
        guard let addItem = tabBar.items?[safe: TabIndex.add] else {
            return
        }

        addItem.title = nil
        addItem.image = UIImage(systemName: "plus")
        addItem.selectedImage = UIImage(systemName: "plus")
    }

    private func installAddActionTabIfNeeded() {
        guard var currentViewControllers = viewControllers,
              currentViewControllers[safe: TabIndex.add] == nil else {
            return
        }

        let addActionViewController = UIViewController()
        addActionViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: TabIndex.add)

        currentViewControllers.append(addActionViewController)
        setViewControllers(currentViewControllers, animated: false)
    }

    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard let viewControllers,
              let tappedIndex = viewControllers.firstIndex(of: viewController),
              tappedIndex == TabIndex.add else {
            return true
        }

        presentAddMenu()
        return false
    }

    private func presentAddMenu() {
        let alertController = UIAlertController(title: "Select Drink Type",
                                                message: nil,
                                                preferredStyle: .actionSheet)

        let drinkTypes = ["Wine", "Beer", "Cocktail"]
        drinkTypes.forEach { drinkType in
            alertController.addAction(UIAlertAction(title: drinkType, style: .default) { _ in
                self.handleAddSelection(for: drinkType)
            })
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = tabBar
            popoverPresentationController.sourceRect = addTabBarItemRect()
        }

        present(alertController, animated: true)
    }

    private func handleAddSelection(for drinkType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: StoryboardScene.addDrinkViewController
        )

        guard let addDrinkViewController = viewController as? AddDrinkViewController else {
            assertionFailure("Expected \(StoryboardScene.addDrinkViewController) to be an AddDrinkViewController")
            return
        }

        addDrinkViewController.selectedDrinkType = drinkType

        let navigationController = UINavigationController(rootViewController: addDrinkViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }

    private func addTabBarItemRect() -> CGRect {
        guard let items = tabBar.items, !items.isEmpty else {
            return CGRect(x: tabBar.bounds.midX, y: tabBar.bounds.minY, width: 1, height: 1)
        }

        let itemWidth = tabBar.bounds.width / CGFloat(items.count)
        let itemCenterX = itemWidth * (CGFloat(TabIndex.add) + 0.5)
        return CGRect(x: itemCenterX, y: tabBar.bounds.minY, width: 1, height: 1)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
