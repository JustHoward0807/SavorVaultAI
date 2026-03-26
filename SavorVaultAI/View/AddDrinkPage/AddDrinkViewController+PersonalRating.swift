//
//  AddDrinkViewController+PersonalRating.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController {

    /// Configures the personal rating button row.
    func configurePersonalRatingSection() {
        let buttons = ratingButtons()
        ratingFeedbackGenerator.prepare()

        for (index, button) in buttons.enumerated() {
            var configuration = UIButton.Configuration.plain()
            configuration.imagePadding = 0
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
            configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
                pointSize: 24,
                weight: .semibold
            )

            button.configuration = configuration
            button.tintColor = .systemYellow
            button.tag = index + 1
            button.accessibilityLabel = "Personal rating \(index + 1)"
            button.setImage(personalRatingImage(isFilled: false), for: .normal)
        }

        updatePersonalRatingUI()
    }

    /// Returns the ordered rating buttons from the stack view.
    func ratingButtons() -> [UIButton] {
        personalRatingButtonsStackView.arrangedSubviews
            .compactMap { $0 as? UIButton }
            .sorted { $0.tag < $1.tag }
    }

    /// Resolves symbol candidates for the selected drink type.
    func personalRatingSymbolCandidates() -> (empty: [String], filled: [String]) {
        switch selectedDrinkType?.lowercased() {
        case "beer":
            return (["beer.mug", "mug"], ["beer.mug.fill", "mug.fill"])
        case "cocktail":
            return (["tropicaldrink", "wineglass"], ["tropicaldrink.fill", "wineglass.fill"])
        case "wine":
            fallthrough
        default:
            return (["wineglass"], ["wineglass.fill"])
        }
    }

    /// Returns the best available symbol image for a rating state.
    func personalRatingImage(isFilled: Bool) -> UIImage? {
        let symbolCandidates = personalRatingSymbolCandidates()
        let names = isFilled ? symbolCandidates.filled : symbolCandidates.empty

        for name in names {
            if let image = UIImage(systemName: name) {
                return image
            }
        }

        return UIImage(systemName: isFilled ? "star.fill" : "star")
    }

    /// Refreshes the rating icons and score label.
    func updatePersonalRatingUI() {
        for button in ratingButtons() {
            let image = personalRatingImage(isFilled: personalRating >= button.tag)
            button.setImage(image, for: .normal)
            button.alpha = personalRating >= button.tag ? 1 : 0.45
        }

        personalRatingValueLabel.text = "\(Double(personalRating).formatted(.number.precision(.fractionLength(1)))) / 5.0"
    }

    /// Updates the selected personal rating value.
    @IBAction func personalRatingButtonTapped(_ sender: UIButton) {
        personalRating = sender.tag
        ratingFeedbackGenerator.impactOccurred()
        ratingFeedbackGenerator.prepare()
        updatePersonalRatingUI()
    }
}
