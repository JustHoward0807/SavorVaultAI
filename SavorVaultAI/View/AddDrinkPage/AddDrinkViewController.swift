//
//  AddDrinkViewController.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/23/26.
//

import CoreData
import UIKit

class AddDrinkViewController: UIViewController {

    @IBOutlet weak var sweetnessSlider: UISlider!
    @IBOutlet weak var bitternessSlider: UISlider!
    @IBOutlet weak var sweetnessValueLabel: UILabel!
    @IBOutlet weak var bitternessValueLabel: UILabel!
    @IBOutlet weak var yearValueLabel: UILabel!
    @IBOutlet weak var yearChevronImageView: UIImageView!
    @IBOutlet weak var personalRatingButtonsStackView: UIStackView!
    @IBOutlet weak var personalRatingValueLabel: UILabel!
    @IBOutlet weak var tastingNotesTextView: UITextView!
    @IBOutlet weak var tastingNotesPlaceholderLabel: UILabel!
    @IBOutlet weak var tastingNotesCharacterCountLabel: UILabel!
    @IBOutlet weak var tastingNotesInputContainerView: UIView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var drinkNameFieldContainer: UIView!
    @IBOutlet weak var drinkNameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectTypeValueLabel: UILabel!
    @IBOutlet weak var categoryChevronImageView: UIImageView!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!

    /// Hidden button overlaid on the category chevron for menu presentation.
    let categoryMenuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    /// Hidden button overlaid on the year chevron for picker activation.
    let yearMenuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var selectedDrinkType: String?
    var selectedWineCategory: WineCategory?
    var selectedBeerCategory: BeerCategory?
    let yearPickerView = UIPickerView()
    /// Hidden text field used to host the year picker input view.
    let yearInputField: UITextField = {
        let field = UITextField(frame: .zero)
        field.isHidden = true
        return field
    }()
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let ratingFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let sweetnessOptions = ["Dry", "Off-Dry", "Unselected", "Semi-Sweet", "Sweet"]
    let bitternessOptions = ["Smooth", "Rounded", "Unselected", "Bold", "Sharp"]
    let tastingNotesMaximumCharacterCount = 200
    let maximumPhotoCount = 5
    var lastSweetnessPreviewIndex = 2
    var lastBitternessPreviewIndex = 2
    var personalRating = 0
    var capturedPhotos: [UIImage] = []
    var viewModel: AddDrinkViewModel?
    lazy var availableYears: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(stride(from: currentYear, through: 1900, by: -1))
    }()
    /// Year picker display options with "Unknown" as the first entry.
    lazy var yearDisplayOptions: [String] = {
        ["Unknown"] + availableYears.map { String($0) }
    }()
    var onSaveSuccess: (() -> Void)?
    var persistenceServiceOverride: DrinkPersisting?
    var documentsDirectoryURLOverride: URL?

    /// Configures the add drink screen after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedDrinkType ?? "Add Drink"
        configureViewModelIfNeeded()
        configureNavigationItems()
        configureDrinkNameField()
        configureCategoryMenu()
        configureTasteSliders()
        configureYearPicker()
        configurePersonalRatingSection()
        configureTastingNotesSection()
        configurePhotoSection()
        configureKeyboardHandling()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePhotoCollectionLayoutIfNeeded()
    }

    /// Configures the drink name field container so tapping anywhere activates the text field.
    func configureDrinkNameField() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drinkNameContainerTapped))
        drinkNameFieldContainer.addGestureRecognizer(tapGesture)
    }

    @objc private func drinkNameContainerTapped() {
        drinkNameTextField.becomeFirstResponder()
    }

    /// Wires the view model with the default persistence service when the screen is loaded from storyboard.
    func configureViewModelIfNeeded() {
        if viewModel != nil {
            return
        }

        viewModel = AddDrinkViewModel(persistenceService: persistenceServiceOverride ?? makeDefaultPersistenceService())
    }

    /// Persists the current form content through the view model.
    func saveDrink() {
        guard let viewModel else {
            presentSaveAlert(title: "Save Failed", message: AddDrinkSaveError.persistenceUnavailable.errorDescription ?? "The drink could not be saved.")
            return
        }

        do {
            try viewModel.saveDrink(makeFormInput())
            if let onSaveSuccess {
                onSaveSuccess()
            } else {
                dismiss(animated: true)
            }
        } catch let error as AddDrinkSaveError {
            let title: String

            switch error {
            case .drinkNameRequired:
                title = "Drink Name Required"
            case .persistenceUnavailable, .saveFailed:
                title = "Save Failed"
            }

            presentSaveAlert(title: title, message: error.errorDescription ?? "The drink could not be saved.")
        } catch {
            presentSaveAlert(title: "Save Failed", message: "The drink could not be saved. Please try again.")
        }
    }

    /// Collects the screen state into the form input expected by the view model.
    func makeFormInput() -> AddDrinkFormInput {
        let viewModel = self.viewModel

        return AddDrinkFormInput(
            drinkName: drinkNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            drinkType: selectedDrinkType,
            category: viewModel?.normalizedCategoryValue(
                selectedWineCategory: selectedWineCategory,
                selectedBeerCategory: selectedBeerCategory
            ),
            sweetnessLevel: Int16(snappedIndex(for: sweetnessSlider)),
            bitternessLevel: Int16(snappedIndex(for: bitternessSlider)),
            personalRating: Int16(personalRating),
            tastingNotes: viewModel?.normalizedTastingNotes(tastingNotesTextView.text),
            year: viewModel?.normalizedYearValue(yearValueLabel.text) ?? "Unknown",
            photos: capturedPhotos
        )
    }

    /// Presents a simple alert when saving cannot proceed.
    func presentSaveAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    /// Builds the app's default persistence service from the Core Data stack.
    func makeDefaultPersistenceService() -> DrinkPersisting? {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return nil
        }

        return DrinkPersistenceService(context: context) { [weak self] in
            if let documentsDirectoryURLOverride = self?.documentsDirectoryURLOverride {
                return documentsDirectoryURLOverride
            }

            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw AddDrinkSaveError.persistenceUnavailable
            }

            return documentsURL
        }
    }

    /// Configures the category selection menu based on the selected drink type.
    func configureCategoryMenu() {
        // Make chevron icons smaller
        let smallChevron = UIImage.SymbolConfiguration(pointSize: 8, weight: .medium)
        categoryChevronImageView.preferredSymbolConfiguration = smallChevron
        yearChevronImageView.preferredSymbolConfiguration = smallChevron

        categoryStackView.isLayoutMarginsRelativeArrangement = true
        categoryStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        dateStackView.isLayoutMarginsRelativeArrangement = true
        dateStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)

        // Place hidden menu button over the category chevron image view
        categoryChevronImageView.isUserInteractionEnabled = true
        categoryChevronImageView.addSubview(categoryMenuButton)
        NSLayoutConstraint.activate([
            categoryMenuButton.topAnchor.constraint(equalTo: categoryChevronImageView.topAnchor),
            categoryMenuButton.bottomAnchor.constraint(equalTo: categoryChevronImageView.bottomAnchor),
            categoryMenuButton.leadingAnchor.constraint(equalTo: categoryChevronImageView.leadingAnchor),
            categoryMenuButton.trailingAnchor.constraint(equalTo: categoryChevronImageView.trailingAnchor),
        ])
        categoryMenuButton.showsMenuAsPrimaryAction = true
        categoryMenuButton.changesSelectionAsPrimaryAction = false

        // Forward taps anywhere on the category card to the hidden menu button
        (categoryStackView as? TappableStackView)?.forwardingTarget = categoryMenuButton

        guard let drinkType = selectedDrinkType?.lowercased() else { return }

        let categories: [UIAction]

        switch drinkType {
        case "wine":
            categories = WineCategory.allCases.map { category in
                UIAction(title: category.displayName) { [weak self] _ in
                    guard let self else { return }
                    self.selectedWineCategory = category
                    self.selectTypeValueLabel.text = category.displayName
                    self.selectTypeValueLabel.textColor = .label
                }
            }
        case "beer":
            categories = BeerCategory.allCases.map { category in
                UIAction(title: category.displayName) { [weak self] _ in
                    guard let self else { return }
                    self.selectedBeerCategory = category
                    self.selectTypeValueLabel.text = category.displayName
                    self.selectTypeValueLabel.textColor = .label
                }
            }
        default:
            return
        }

        categoryMenuButton.menu = UIMenu(title: "", options: .singleSelection, children: categories)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
