//
//  AddDrinkViewController+TastingNotes.swift
//  SavorVaultAI
//

import UIKit

extension AddDrinkViewController: UITextViewDelegate {

    /// Prepares the tasting notes input with placeholder and character count.
    func configureTastingNotesSection() {
        tastingNotesTextView.delegate = self
        tastingNotesTextView.isEditable = true
        tastingNotesTextView.isSelectable = true
        tastingNotesTextView.isUserInteractionEnabled = true
        tastingNotesTextView.isScrollEnabled = true
        tastingNotesTextView.alwaysBounceVertical = true
        tastingNotesTextView.backgroundColor = .systemBackground
        tastingNotesTextView.keyboardDismissMode = .interactive
        tastingNotesTextView.textColor = .label
        tastingNotesTextView.tintColor = .systemBlue
        tastingNotesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 28, right: 10)
        tastingNotesTextView.textContainer.lineFragmentPadding = 0
        scrollView.keyboardDismissMode = .interactive

        tastingNotesInputContainerView.backgroundColor = .secondarySystemBackground
        tastingNotesInputContainerView.layer.cornerRadius = 14
        tastingNotesInputContainerView.layer.borderWidth = 1
        tastingNotesInputContainerView.layer.borderColor = UIColor.separator.cgColor
        tastingNotesInputContainerView.layer.masksToBounds = true
        tastingNotesInputContainerView.isUserInteractionEnabled = true

        tastingNotesPlaceholderLabel.isUserInteractionEnabled = true
        tastingNotesCharacterCountLabel.isUserInteractionEnabled = true
        tastingNotesPlaceholderLabel.textColor = .placeholderText
        tastingNotesCharacterCountLabel.textColor = .secondaryLabel

        let containerTapGesture = UITapGestureRecognizer(target: self, action: #selector(focusTastingNotes))
        containerTapGesture.cancelsTouchesInView = false
        tastingNotesInputContainerView.addGestureRecognizer(containerTapGesture)

        let focusAction = UITapGestureRecognizer(target: self, action: #selector(focusTastingNotes))
        focusAction.cancelsTouchesInView = false
        tastingNotesPlaceholderLabel.addGestureRecognizer(focusAction)

        let counterFocusAction = UITapGestureRecognizer(target: self, action: #selector(focusTastingNotes))
        counterFocusAction.cancelsTouchesInView = false
        tastingNotesCharacterCountLabel.addGestureRecognizer(counterFocusAction)

        let dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTapGesture.cancelsTouchesInView = false
        dismissKeyboardTapGesture.delegate = self
        scrollView.addGestureRecognizer(dismissKeyboardTapGesture)

        updateTastingNotesUI()
    }

    /// Moves focus into the tasting notes input.
    @objc func focusTastingNotes() {
        tastingNotesTextView.becomeFirstResponder()
    }

    /// Dismisses the keyboard when the user taps away from the notes field.
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    /// Keeps the tasting notes container visible while the user edits.
    func scrollToTastingNotesIfNeeded() {
        guard tastingNotesTextView.isFirstResponder else { return }

        let targetFrame = scrollView.convert(tastingNotesInputContainerView.bounds, from: tastingNotesInputContainerView)
        scrollView.scrollRectToVisible(targetFrame.insetBy(dx: 0, dy: -20), animated: false)
    }

    /// Keeps the caret visible as the notes content grows.
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToTastingNotesIfNeeded()
    }

    /// Updates the placeholder visibility and character count label.
    func updateTastingNotesUI() {
        let characterCount = tastingNotesTextView.text.count
        tastingNotesPlaceholderLabel.isHidden = characterCount > 0
        tastingNotesCharacterCountLabel.text = "\(characterCount)/\(tastingNotesMaximumCharacterCount)"
    }

    /// Keeps the notes field within the supported character limit.
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        return updatedText.count <= tastingNotesMaximumCharacterCount
    }

    /// Refreshes the notes UI as the user types.
    func textViewDidChange(_ textView: UITextView) {
        updateTastingNotesUI()
        scrollToTastingNotesIfNeeded()
    }
}

extension AddDrinkViewController {

    /// Registers keyboard observers so the notes field stays visible while editing.
    func configureKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// Updates scroll insets to avoid the keyboard overlapping the notes field.
    @objc func handleKeyboardFrameChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let keyboardOverlap = max(0, view.bounds.maxY - keyboardFrameInView.minY)
        let bottomInset = max(0, keyboardOverlap - view.safeAreaInsets.bottom + 16)

        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRawValue << 16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            self.scrollToTastingNotesIfNeeded()
        }
    }

    /// Restores the default scroll insets when the keyboard dismisses.
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurveRawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
            return
        }

        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRawValue << 16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

extension AddDrinkViewController: UIGestureRecognizerDelegate {

    /// Keeps taps inside the text view focused while allowing outside taps to dismiss the keyboard.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        return !touchedView.isDescendant(of: tastingNotesInputContainerView)
    }
}
