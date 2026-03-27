//
//  DrinkCardCell.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/26/26.
//
//  Shared card cell used by the Home "Recently Added" section and the List page.
//  Configure via configure(with:) using a DrinkCardItem value.

import UIKit

struct DrinkCardItem {
    let name: String
    let category: String
}

final class DrinkCardCell: UICollectionViewCell {

    static let reuseIdentifier = "DrinkCardCell"

    // MARK: - UI Elements

    private let backgroundCardView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let nameLabel = UILabel()
    private let categoryLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backgroundCardView.bounds
        contentView.layer.shadowPath = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: 18
        ).cgPath
    }

    // MARK: - Configuration

    func configure(with item: DrinkCardItem) {
        nameLabel.text = item.name
        categoryLabel.text = item.category
    }

    // MARK: - Private Setup

    private func setupCell() {
        // contentView: shadow host — must not clip
        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.10
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)

        // Background card — clips to apply corner radius
        backgroundCardView.backgroundColor = .secondarySystemBackground
        backgroundCardView.layer.cornerRadius = 18
        backgroundCardView.layer.cornerCurve = .continuous
        backgroundCardView.clipsToBounds = true
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundCardView)

        // Gradient overlay for text legibility (bottom half, clear → dark)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.45).cgColor]
        gradientLayer.locations = [0.5, 1.0]
        backgroundCardView.layer.addSublayer(gradientLayer)

        // Category label (above name, bottom of card)
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        categoryLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        categoryLabel.numberOfLines = 1
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(categoryLabel)

        // Name label (bottommost text on card)
        nameLabel.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize,
            weight: .semibold
        )
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            // backgroundCardView fills contentView
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // nameLabel at bottom-left of card
            nameLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: -12),

            // categoryLabel sits directly above nameLabel
            categoryLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -4),
        ])
    }
}
