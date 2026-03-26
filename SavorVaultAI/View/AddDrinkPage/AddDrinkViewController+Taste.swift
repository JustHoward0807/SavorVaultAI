//
//  AddDrinkViewController+Taste.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController {

    /// Prepares both taste sliders and their initial labels.
    func configureTasteSliders() {
        configureSlider(sweetnessSlider, selectedIndex: 2)
        configureSlider(bitternessSlider, selectedIndex: 2)
        selectionFeedbackGenerator.prepare()
        updateTasteLabel(for: sweetnessSlider)
        updateTasteLabel(for: bitternessSlider)
    }

    /// Applies the shared slider configuration.
    func configureSlider(_ slider: UISlider, selectedIndex: Int) {
        slider.minimumValue = 0
        slider.maximumValue = 4
        slider.isContinuous = true
        slider.value = Float(selectedIndex)
    }

    /// Returns the nearest discrete index for a slider value.
    func snappedIndex(for slider: UISlider) -> Int {
        Int(round(slider.value))
    }

    /// Snaps a slider to the nearest stop and refreshes its label.
    func applySnap(to slider: UISlider, animated: Bool) {
        let index = snappedIndex(for: slider)
        slider.setValue(Float(index), animated: animated)
        updateTasteLabel(for: slider)
    }

    /// Updates the visible label for the given taste slider.
    func updateTasteLabel(for slider: UISlider) {
        let index = snappedIndex(for: slider)

        if slider === sweetnessSlider {
            sweetnessValueLabel.text = sweetnessOptions[index]
        } else if slider === bitternessSlider {
            bitternessValueLabel.text = bitternessOptions[index]
        }
    }

    /// Triggers haptics when a slider crosses into a new discrete step.
    func handlePreviewChange(for slider: UISlider) {
        let index = snappedIndex(for: slider)

        if slider === sweetnessSlider {
            guard index != lastSweetnessPreviewIndex else { return }
            lastSweetnessPreviewIndex = index
        } else if slider === bitternessSlider {
            guard index != lastBitternessPreviewIndex else { return }
            lastBitternessPreviewIndex = index
        } else {
            return
        }

        selectionFeedbackGenerator.selectionChanged()
        selectionFeedbackGenerator.prepare()
    }

    /// Refreshes sweetness feedback while the slider moves.
    @IBAction func sweetnessSliderChanged(_ sender: UISlider) {
        handlePreviewChange(for: sender)
        updateTasteLabel(for: sender)
    }

    /// Refreshes bitterness feedback while the slider moves.
    @IBAction func bitternessSliderChanged(_ sender: UISlider) {
        handlePreviewChange(for: sender)
        updateTasteLabel(for: sender)
    }

    /// Snaps the sweetness slider when interaction ends.
    @IBAction func sweetnessSliderDidEndEditing(_ sender: UISlider) {
        applySnap(to: sender, animated: true)
        lastSweetnessPreviewIndex = snappedIndex(for: sender)
    }

    /// Snaps the bitterness slider when interaction ends.
    @IBAction func bitternessSliderDidEndEditing(_ sender: UISlider) {
        applySnap(to: sender, animated: true)
        lastBitternessPreviewIndex = snappedIndex(for: sender)
    }
}
