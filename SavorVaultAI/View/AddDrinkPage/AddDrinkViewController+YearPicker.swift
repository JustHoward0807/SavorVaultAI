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
        yearTextField.inputView = yearPickerView
        yearTextField.inputAccessoryView = makeYearAccessoryToolbar()
        yearTextField.clearButtonMode = .never

        if let firstYear = availableYears.first {
            yearTextField.text = String(firstYear)
            yearPickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }

    /// Builds the accessory toolbar for the year picker.
    func makeYearAccessoryToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(
                title: "Done",
                style: .prominent,
                target: self,
                action: #selector(didTapDoneOnYearPicker)
            )
        ]
        return toolbar
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
