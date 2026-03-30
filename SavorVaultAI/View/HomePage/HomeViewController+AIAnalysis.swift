//
//  HomeViewController+AIAnalysis.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/26/26.
//

import UIKit

extension HomeViewController {

    // MARK: - AI Analysis Section Setup

    func configureAIAnalysisSection() {
        setupAnalysisCard()
        setupTabSelector()
        setupAnalysisContent()
        applyAnalysisCardConstraints()
    }

    // MARK: - Tab Interaction

    @objc func tabButtonTapped(_ sender: UIButton) {
        guard sender.tag != selectedTabIndex else { return }
        selectedTabIndex = sender.tag
        let placeholders = ["Wine Analysis", "Beer Analysis", "Cocktail Analysis"]
        analysisLabel.text = placeholders[selectedTabIndex]
        updateTabButtonAppearances()
        animatePillToSelectedTab()
    }

    func updateTabButtonAppearances() {
        tabButtons.enumerated().forEach { index, button in
            var config = button.configuration ?? UIButton.Configuration.plain()
            config.baseForegroundColor = index == selectedTabIndex ? .white : .secondaryLabel
            button.configuration = config
        }
    }

    func animatePillToSelectedTab() {
        guard tabSelectorView.bounds.width > 0 else { return }
        let pillWidth = (tabSelectorView.bounds.width - 8) / 3
        selectedPillLeadingConstraint.constant = 4 + CGFloat(selectedTabIndex) * pillWidth
        UIView.animate(springDuration: 0.4, bounce: 0.2) {
            self.tabSelectorView.layoutIfNeeded()
        }
    }

    /// Recalculates pill position. Called from viewDidLayoutSubviews on every layout pass.
    func updatePillLayout() {
        guard tabSelectorView.bounds.width > 0 else { return }
        let pillWidth = (tabSelectorView.bounds.width - 8) / 3
        selectedPillLeadingConstraint.constant = 4 + CGFloat(selectedTabIndex) * pillWidth
    }

    // MARK: - Private Helpers

    private func setupAnalysisCard() {
        aiAnalysisCardView.backgroundColor = .secondarySystemBackground
        aiAnalysisCardView.layer.cornerRadius = 20
        aiAnalysisCardView.layer.cornerCurve = .continuous
        aiAnalysisCardView.clipsToBounds = true
        aiAnalysisCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aiAnalysisCardView)
    }

    private func setupTabSelector() {
        // Tab selector background (pill container)
        tabSelectorView.backgroundColor = .tertiarySystemBackground
        tabSelectorView.layer.cornerRadius = 12
        tabSelectorView.layer.cornerCurve = .continuous
        tabSelectorView.translatesAutoresizingMaskIntoConstraints = false
        aiAnalysisCardView.addSubview(tabSelectorView)

        // Floating pill that slides under the selected tab
        selectedPillView.backgroundColor = .black
        selectedPillView.layer.cornerRadius = 9
        selectedPillView.layer.cornerCurve = .continuous
        selectedPillView.layer.shadowColor = UIColor.black.cgColor
        selectedPillView.layer.shadowOpacity = 0.08
        selectedPillView.layer.shadowRadius = 6
        selectedPillView.layer.shadowOffset = .zero
        selectedPillView.translatesAutoresizingMaskIntoConstraints = false
        tabSelectorView.addSubview(selectedPillView)

        // Pill position constraints — leading is animated, width is 1/3 of selector minus padding
        selectedPillLeadingConstraint = selectedPillView.leadingAnchor.constraint(
            equalTo: tabSelectorView.leadingAnchor, constant: 4
        )
        selectedPillWidthConstraint = selectedPillView.widthAnchor.constraint(
            equalTo: tabSelectorView.widthAnchor, multiplier: 1.0 / 3.0, constant: -8.0 / 3.0
        )

        NSLayoutConstraint.activate([
            selectedPillLeadingConstraint,
            selectedPillWidthConstraint,
            selectedPillView.topAnchor.constraint(equalTo: tabSelectorView.topAnchor, constant: 4),
            selectedPillView.bottomAnchor.constraint(equalTo: tabSelectorView.bottomAnchor, constant: -4),
        ])

        // Tab buttons laid out in a horizontal stack view on top of the pill
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabSelectorView.addSubview(stackView)

        let tabTitles = ["Wine", "Beer", "Cocktail"]
        tabTitles.enumerated().forEach { index, title in
            let button = makeTabButton(title: title, index: index)
            stackView.addArrangedSubview(button)
            tabButtons.append(button)
        }
        updateTabButtonAppearances()

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: tabSelectorView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: tabSelectorView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabSelectorView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: tabSelectorView.bottomAnchor),
        ])
    }

    private func setupAnalysisContent() {
        analysisContentContainer.translatesAutoresizingMaskIntoConstraints = false
        aiAnalysisCardView.addSubview(analysisContentContainer)

        analysisLabel.text = "Wine Analysis"
        analysisLabel.textAlignment = .center
        analysisLabel.font = UIFont.preferredFont(forTextStyle: .body)
        analysisLabel.textColor = .secondaryLabel
        analysisLabel.translatesAutoresizingMaskIntoConstraints = false
        analysisContentContainer.addSubview(analysisLabel)

        NSLayoutConstraint.activate([
            analysisLabel.centerXAnchor.constraint(equalTo: analysisContentContainer.centerXAnchor),
            analysisLabel.centerYAnchor.constraint(equalTo: analysisContentContainer.centerYAnchor),
            analysisLabel.leadingAnchor.constraint(greaterThanOrEqualTo: analysisContentContainer.leadingAnchor, constant: 16),
            analysisLabel.trailingAnchor.constraint(lessThanOrEqualTo: analysisContentContainer.trailingAnchor, constant: -16),
        ])
    }

    private func applyAnalysisCardConstraints() {
        NSLayoutConstraint.activate([
            // Tab selector inside the card
            tabSelectorView.topAnchor.constraint(equalTo: aiAnalysisCardView.topAnchor, constant: 16),
            tabSelectorView.leadingAnchor.constraint(equalTo: aiAnalysisCardView.leadingAnchor, constant: 16),
            tabSelectorView.trailingAnchor.constraint(equalTo: aiAnalysisCardView.trailingAnchor, constant: -16),
            tabSelectorView.heightAnchor.constraint(equalToConstant: 44),

            // Analysis content container below tab selector
            analysisContentContainer.topAnchor.constraint(equalTo: tabSelectorView.bottomAnchor, constant: 16),
            analysisContentContainer.leadingAnchor.constraint(equalTo: aiAnalysisCardView.leadingAnchor),
            analysisContentContainer.trailingAnchor.constraint(equalTo: aiAnalysisCardView.trailingAnchor),
            analysisContentContainer.bottomAnchor.constraint(equalTo: aiAnalysisCardView.bottomAnchor, constant: -24),
            analysisContentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
    }

    private func makeTabButton(title: String, index: Int) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .secondaryLabel
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(
                ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize,
                weight: .semibold,
            )
            return outgoing
        }
        let button = UIButton(configuration: config)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }
}
