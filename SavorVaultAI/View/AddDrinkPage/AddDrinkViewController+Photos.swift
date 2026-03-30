//
//  AddDrinkViewController+Photos.swift
//  SavorVaultAI
//

import AVFoundation
import UIKit

// MARK: - Photo Section Setup & Helpers

extension AddDrinkViewController {

    // MARK: Configuration

    /// Configures the photo collection view with a flow layout, registers cell types, and performs an initial data reload.
    func configurePhotoSection() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.clipsToBounds = false
        photoCollectionView.showsVerticalScrollIndicator = false
        photoCollectionView.isScrollEnabled = false
        photoCollectionView.contentInset = .zero
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.register(AddDrinkPhotoCell.self, forCellWithReuseIdentifier: AddDrinkPhotoCell.reuseIdentifier)
        photoCollectionView.register(AddDrinkPhotoAddCell.self, forCellWithReuseIdentifier: AddDrinkPhotoAddCell.reuseIdentifier)
        photoCollectionView.reloadData()
        updatePhotoCollectionHeight()
    }

    // MARK: Item Counting

    /// Returns the total number of items to display, including an extra slot for the "Add Photo" tile when the limit hasn't been reached.
    func photoItemCount() -> Int {
        capturedPhotos.count < maximumPhotoCount ? capturedPhotos.count + 1 : capturedPhotos.count
    }

    /// Determines whether the cell at the given index path should display the "Add Photo" tile.
    /// - Parameter indexPath: The index path of the cell to check.
    /// - Returns: `true` if the tile should be the "Add Photo" button; `false` if it should show a captured photo.
    func shouldShowAddPhotoTile(at indexPath: IndexPath) -> Bool {
        capturedPhotos.count < maximumPhotoCount && indexPath.item == capturedPhotos.count
    }

    // MARK: Grid Layout Metrics

    /// Calculates column count and cell dimensions for the photo grid based on the available width.
    /// - Parameter width: The available width for the collection view content.
    /// - Returns: A tuple containing the number of columns, the item width, and the item height.
    func photoGridMetrics(for width: CGFloat) -> (columns: Int, itemWidth: CGFloat, itemHeight: CGFloat) {
        let minimumItemWidth: CGFloat = 148
        let spacing: CGFloat = 12
        let availableWidth = max(width, minimumItemWidth)
        let columns = max(2, Int((availableWidth + spacing) / (minimumItemWidth + spacing)))
        let totalSpacing = CGFloat(columns - 1) * spacing
        let itemWidth = floor((availableWidth - totalSpacing) / CGFloat(columns))
        let itemHeight = max(136, itemWidth - 28)
        return (columns, itemWidth, itemHeight)
    }

    /// Recalculates the flow layout item size and collection view height when the collection view bounds change.
    func updatePhotoCollectionLayoutIfNeeded() {
        guard photoCollectionView.bounds.width > 0 else { return }

        if let flowLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let metrics = photoGridMetrics(for: photoCollectionView.bounds.width)
            flowLayout.itemSize = CGSize(width: metrics.itemWidth, height: metrics.itemHeight)
            flowLayout.invalidateLayout()
        }

        updatePhotoCollectionHeight()
    }

    /// Updates the photo collection view's height constraint to fit the current number of rows.
    func updatePhotoCollectionHeight() {
        guard photoCollectionView.bounds.width > 0 else { return }

        let metrics = photoGridMetrics(for: photoCollectionView.bounds.width)
        let itemCount = max(photoItemCount(), 1)
        let rows = Int(ceil(Double(itemCount) / Double(metrics.columns)))
        let spacing = CGFloat(max(rows - 1, 0)) * 12
        let sectionInsets: UIEdgeInsets

        if let flowLayout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            sectionInsets = flowLayout.sectionInset
        } else {
            sectionInsets = .zero
        }

        photoCollectionHeightConstraint.constant = sectionInsets.top + (CGFloat(rows) * metrics.itemHeight) + spacing + sectionInsets.bottom + 8
    }

    // MARK: Camera Flow

    /// Initiates the camera capture flow after checking device availability and authorization status.
    ///
    /// Presents appropriate alerts when the camera is unavailable or access is denied.
    func presentCameraFlow() {
        guard capturedPhotos.count < maximumPhotoCount else { return }

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoAlert(title: "Camera Unavailable", message: "This device does not have an available camera.")
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCameraPicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }

                    if granted {
                        self.presentCameraPicker()
                    } else {
                        self.presentPhotoAlert(
                            title: "Camera Access Needed",
                            message: "Allow camera access in Settings to capture drink photos."
                        )
                    }
                }
            }
        case .denied, .restricted:
            presentPhotoAlert(
                title: "Camera Access Needed",
                message: "Allow camera access in Settings to capture drink photos."
            )
        @unknown default:
            presentPhotoAlert(title: "Camera Error", message: "Camera access could not be determined.")
        }
    }

    /// Presents the system camera picker for capturing a photo.
    func presentCameraPicker() {
        guard presentedViewController == nil else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: Alerts

    /// Displays a simple alert with a title, message, and an "OK" dismiss button.
    /// - Parameters:
    ///   - title: The alert title.
    ///   - message: The alert body text.
    func presentPhotoAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension AddDrinkViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoItemCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if shouldShowAddPhotoTile(at: indexPath) {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddDrinkPhotoAddCell.reuseIdentifier,
                for: indexPath
            ) as! AddDrinkPhotoAddCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AddDrinkPhotoCell.reuseIdentifier,
            for: indexPath
        ) as! AddDrinkPhotoCell
        cell.configure(with: capturedPhotos[indexPath.item])
        cell.onDelete = { [weak self] in
            guard let self else { return }
            self.capturedPhotos.remove(at: indexPath.item)
            self.photoCollectionView.reloadData()
            self.updatePhotoCollectionHeight()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard shouldShowAddPhotoTile(at: indexPath) else { return }
        presentCameraFlow()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let metrics = photoGridMetrics(for: collectionView.bounds.width)
        return CGSize(width: metrics.itemWidth, height: metrics.itemHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension AddDrinkViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    /// Dismisses the picker when the user cancels photo capture.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    /// Appends the captured photo to `capturedPhotos` and refreshes the collection view.
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage, capturedPhotos.count < maximumPhotoCount {
            capturedPhotos.append(image)
        }

        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.photoCollectionView.reloadData()
            self.updatePhotoCollectionHeight()
        }
    }
}

// MARK: - AddDrinkPhotoCell

/// A collection view cell that displays a captured drink photo with a delete button.
private final class AddDrinkPhotoCell: UICollectionViewCell {

    static let reuseIdentifier = "AddDrinkPhotoCell"

    /// Called when the user taps the delete button.
    var onDelete: (() -> Void)?

    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 18
    }

    /// Updates the cell's image view with the given photo.
    /// - Parameter image: The drink photo to display.
    func configure(with image: UIImage) {
        imageView.image = image
    }

    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    private func configureCell() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = 13
        deleteButton.layer.masksToBounds = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            deleteButton.widthAnchor.constraint(equalToConstant: 26),
            deleteButton.heightAnchor.constraint(equalToConstant: 26),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -6),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 6)
        ])
    }
}

// MARK: - AddDrinkPhotoAddCell

/// A collection view cell that displays a dashed-border "Add Photo" button with a camera icon.
private final class AddDrinkPhotoAddCell: UICollectionViewCell {

    static let reuseIdentifier = "AddDrinkPhotoAddCell"

    private let cardView = UIView()
    private let iconView = UIImageView(image: UIImage(systemName: "camera.fill"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    private let dashedBorderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard cardView.bounds.width.isFinite,
              cardView.bounds.height.isFinite,
              cardView.bounds.width > dashedBorderLayer.lineWidth,
              cardView.bounds.height > dashedBorderLayer.lineWidth else {
            dashedBorderLayer.path = nil
            dashedBorderLayer.frame = .zero
            return
        }

        let insetBounds = cardView.bounds.insetBy(dx: dashedBorderLayer.lineWidth / 2, dy: dashedBorderLayer.lineWidth / 2)
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: insetBounds,
            cornerRadius: max(0, cardView.layer.cornerRadius - (dashedBorderLayer.lineWidth / 2))
        ).cgPath
        dashedBorderLayer.frame = cardView.bounds
    }

    private func configureCell() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.masksToBounds = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .tertiarySystemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.cornerCurve = .continuous
        cardView.layer.masksToBounds = true

        dashedBorderLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.45).cgColor
        dashedBorderLayer.fillColor = UIColor.clear.cgColor
        dashedBorderLayer.lineWidth = 1.5
        dashedBorderLayer.lineDashPattern = [6, 5]
        cardView.layer.addSublayer(dashedBorderLayer)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false

        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.text = "Add Photo"

        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "Tap to capture"

        contentView.addSubview(cardView)
        cardView.addSubview(stackView)
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),

            stackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: cardView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12)
        ])
    }
}
