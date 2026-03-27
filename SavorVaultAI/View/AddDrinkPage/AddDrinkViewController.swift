//
//  AddDrinkViewController.swift
//  SavorVaultAI
//
//  Created by Lung-Hao Tung on 3/23/26.
//

import UIKit

class AddDrinkViewController: UIViewController {

    @IBOutlet weak var sweetnessSlider: UISlider!
    @IBOutlet weak var bitternessSlider: UISlider!
    @IBOutlet weak var sweetnessValueLabel: UILabel!
    @IBOutlet weak var bitternessValueLabel: UILabel!
    @IBOutlet weak var yearTextField: UITextField!
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
    @IBOutlet weak var selectTypeButton: UIButton!

    var selectedDrinkType: String?
    var selectedWineCategory: WineCategory?
    var selectedBeerCategory: BeerCategory?
    let yearPickerView = UIPickerView()
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
    lazy var availableYears: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(stride(from: currentYear, through: 1900, by: -1))
    }()

    /// Configures the add drink screen after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedDrinkType ?? "Add Drink"
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

    /// Configures the category selection menu based on the selected drink type.
    func configureCategoryMenu() {
        guard let drinkType = selectedDrinkType?.lowercased() else {
            selectTypeButton.menu = nil
            return
        }

        let categories: [UIAction]

        switch drinkType {
        case "wine":
            categories = WineCategory.allCases.map { category in
                UIAction(title: category.displayName) { [weak self] _ in
                    guard let self else { return }
                    self.selectedWineCategory = category
                    UIView.performWithoutAnimation {
                        self.selectTypeButton.setTitle(category.displayName, for: .normal)
                        self.selectTypeButton.layoutIfNeeded()
                    }
                }
            }
        case "beer":
            categories = BeerCategory.allCases.map { category in
                UIAction(title: category.displayName) { [weak self] _ in
                    guard let self else { return }
                    self.selectedBeerCategory = category
                    UIView.performWithoutAnimation {
                        self.selectTypeButton.setTitle(category.displayName, for: .normal)
                        self.selectTypeButton.layoutIfNeeded()
                    }
                }
            }
        default:
            selectTypeButton.menu = nil
            return
        }

        selectTypeButton.menu = UIMenu(title: "", options: .singleSelection, children: categories)
        selectTypeButton.showsMenuAsPrimaryAction = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
