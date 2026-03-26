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
    @IBOutlet weak var scrollView: UIScrollView!

    var selectedDrinkType: String?
    let yearPickerView = UIPickerView()
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let ratingFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let sweetnessOptions = ["Dry", "Off-Dry", "Unselected", "Semi-Sweet", "Sweet"]
    let bitternessOptions = ["Smooth", "Rounded", "Unselected", "Bold", "Sharp"]
    let tastingNotesMaximumCharacterCount = 200
    var lastSweetnessPreviewIndex = 2
    var lastBitternessPreviewIndex = 2
    var personalRating = 0
    lazy var availableYears: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(stride(from: currentYear, through: 1900, by: -1))
    }()

    /// Configures the add drink screen after the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedDrinkType ?? "Add Drink"
        configureNavigationItems()
        configureTasteSliders()
        configureYearPicker()
        configurePersonalRatingSection()
        configureTastingNotesSection()
        configureKeyboardHandling()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
