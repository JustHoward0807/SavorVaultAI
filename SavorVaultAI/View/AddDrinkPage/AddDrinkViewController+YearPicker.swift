//
//  AddDrinkViewController+YearPicker.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController {

    /// Configures the year picker and default value.
    func configureYearPicker() {
        yearPickerView.dataSource = self
        yearPickerView.delegate = self
        yearTextField.inputView = makeYearPickerInputView()
        yearTextField.clearButtonMode = .never

        yearTextField.borderStyle = .none
        yearTextField.backgroundColor = .tertiarySystemFill
        yearTextField.layer.cornerRadius = 10
        yearTextField.clipsToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        yearTextField.leftView = paddingView
        yearTextField.leftViewMode = .always
        yearTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        yearTextField.rightViewMode = .always

        if let firstYear = availableYears.first {
            yearTextField.text = String(firstYear)
            yearPickerView.selectRow(0, inComponent: 0, animated: false)
        }
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
        yearTextField.text = String(availableYears[selectedRow])
        yearTextField.resignFirstResponder()
    }
}

extension AddDrinkViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    /// Returns the number of components used by the year picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    /// Returns the number of available years to display.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        availableYears.count
    }

    /// Provides the display title for a year row.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        String(availableYears[row])
    }

    /// Updates the text field when a year is selected.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearTextField.text = String(availableYears[row])
    }
}
