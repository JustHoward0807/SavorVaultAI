//
//  AddDrinkViewController+YearPicker.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController {

    /// Configures the year picker triggered by the pencil button.
    func configureYearPicker() {
        yearPickerView.dataSource = self
        yearPickerView.delegate = self

        // Hidden text field to host the picker input view
        yearInputField.inputView = makeYearPickerInputView()
        view.addSubview(yearInputField)

        yearEditButton.addTarget(self, action: #selector(didTapYearEditButton), for: .touchUpInside)

        // Default to the first actual year (index 1, skipping "Unknown")
        if yearDisplayOptions.count > 1 {
            yearValueLabel.text = yearDisplayOptions[1]
            yearValueLabel.textColor = .label
            yearPickerView.selectRow(1, inComponent: 0, animated: false)
        }
    }

    /// Opens the year picker when the pencil button is tapped.
    @objc func didTapYearEditButton() {
        yearInputField.becomeFirstResponder()
    }

    /// Creates a combined input view containing the year picker and a Done button.
    func makeYearPickerInputView() -> UIView {
        let screenWidth = view.window?.windowScene?.screen.bounds.width ?? view.bounds.width
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 260))
        containerView.backgroundColor = .secondarySystemBackground

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        doneButton.addTarget(self, action: #selector(didTapDoneOnYearPicker), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        yearPickerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(doneButton)
        containerView.addSubview(separator)
        containerView.addSubview(yearPickerView)

        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 30),

            separator.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            yearPickerView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            yearPickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            yearPickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            yearPickerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    /// Commits the selected year and dismisses the picker.
    @objc func didTapDoneOnYearPicker() {
        let selectedRow = yearPickerView.selectedRow(inComponent: 0)
        yearValueLabel.text = yearDisplayOptions[selectedRow]
        yearValueLabel.textColor = .label
        yearInputField.resignFirstResponder()
    }
}

extension AddDrinkViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    /// Returns the number of components used by the year picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    /// Returns the number of available year options to display.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        yearDisplayOptions.count
    }

    /// Provides the display title for a year row.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        yearDisplayOptions[row]
    }

    /// Updates the year label when a year is selected.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearValueLabel.text = yearDisplayOptions[row]
        yearValueLabel.textColor = .label
    }
}
