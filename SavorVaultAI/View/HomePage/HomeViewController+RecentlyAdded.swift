//
//  HomeViewController+RecentlyAdded.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/26/26.
//

import UIKit

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Section Setup

    func configureRecentlyAddedSection() {
        // Header label
        recentlyAddedHeaderLabel.text = "Recently Added"
        recentlyAddedHeaderLabel.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize,
            weight: .semibold
        )
        recentlyAddedHeaderLabel.textColor = .label
        recentlyAddedHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentlyAddedHeaderLabel)

        // Collection view
        recentlyAddedCollectionView.backgroundColor = .clear
        // Allow card shadows to bleed outside the collection view frame
        recentlyAddedCollectionView.clipsToBounds = false
        recentlyAddedCollectionView.showsHorizontalScrollIndicator = false
        recentlyAddedCollectionView.dataSource = self
        recentlyAddedCollectionView.delegate = self
        recentlyAddedCollectionView.register(
            DrinkCardCell.self,
            forCellWithReuseIdentifier: DrinkCardCell.reuseIdentifier
        )
        recentlyAddedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(recentlyAddedCollectionView)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recentlyAddedItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DrinkCardCell.reuseIdentifier,
            for: indexPath
        ) as! DrinkCardCell
        cell.configure(with: recentlyAddedItems[indexPath.item])
        return cell
    }

    // MARK: - UICollectionViewDelegate — Scroll-in Animation

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // Start off-screen to the right and transparent
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 40, y: 0)

        UIView.animate(
            withDuration: 0.4,
            delay: 0.05 * Double(indexPath.item % 3),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}
