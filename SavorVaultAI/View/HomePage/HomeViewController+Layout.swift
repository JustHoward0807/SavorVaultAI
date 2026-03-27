//
//  HomeViewController+Layout.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/26/26.
//

import UIKit

extension HomeViewController {

    // MARK: - Scroll Container

    func configureScrollContainer() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            // scrollView fills the view (extends under tab bar for bounce)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // contentView fills the scroll content area
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // Suppress horizontal scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    // MARK: - Master Vertical Layout

    func applyLayoutConstraints() {
        NSLayoutConstraint.activate([
            // AI Analysis card — 16pt horizontal margins
            aiAnalysisCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            aiAnalysisCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            aiAnalysisCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Recently Added header — 16pt horizontal margins
            recentlyAddedHeaderLabel.topAnchor.constraint(equalTo: aiAnalysisCardView.bottomAnchor, constant: 28),
            recentlyAddedHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentlyAddedHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Recently Added collection — 16pt horizontal margins, fixed height
            recentlyAddedCollectionView.topAnchor.constraint(equalTo: recentlyAddedHeaderLabel.bottomAnchor, constant: 12),
            recentlyAddedCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentlyAddedCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            recentlyAddedCollectionView.heightAnchor.constraint(equalToConstant: 220),

            // Scroll content bottom — allows future sections to extend naturally
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: recentlyAddedCollectionView.bottomAnchor, constant: 32),
        ])
    }
}
