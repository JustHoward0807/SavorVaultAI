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
    @IBOutlet weak var yearValueLabel: UILabel!
    @IBOutlet weak var yearEditButton: UIButton!
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
    @IBOutlet weak var categoryChevronButton: UIButton!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var dateStackView: UIStackView!

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
    lazy var availableYears: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(stride(from: currentYear, through: 1900, by: -1))
    }()
    /// Year picker display options with "Unknown" as the first entry.
    lazy var yearDisplayOptions: [String] = {
        ["Unknown"] + availableYears.map { String($0) }
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
        // Make chevron icons smaller
        let smallChevron = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        categoryChevronButton.setPreferredSymbolConfiguration(smallChevron, forImageIn: .normal)
        yearEditButton.setPreferredSymbolConfiguration(smallChevron, forImageIn: .normal)

        categoryStackView.isLayoutMarginsRelativeArrangement = true
        categoryStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        dateStackView.isLayoutMarginsRelativeArrangement = true
        dateStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        categoryChevronButton.showsMenuAsPrimaryAction = true
        categoryChevronButton.changesSelectionAsPrimaryAction = false

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

        categoryChevronButton.menu = UIMenu(title: "", options: .singleSelection, children: categories)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
