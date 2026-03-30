//
//  DrinkPersistenceService.swift
//  SavorVaultAI
//

import CoreData
import UIKit

final class DrinkPersistenceService: DrinkPersisting {

    private let context: NSManagedObjectContext
    private let fileManager: FileManager
    private let documentsDirectoryURLProvider: () throws -> URL

    init(
        context: NSManagedObjectContext,
        fileManager: FileManager = .default,
        documentsDirectoryURLProvider: @escaping () throws -> URL
    ) {
        self.context = context
        self.fileManager = fileManager
        self.documentsDirectoryURLProvider = documentsDirectoryURLProvider
    }

    func saveDrink(_ input: AddDrinkFormInput) throws {
        let drinkID = UUID()
        let now = Date()
        let drink = Drink(context: context)

        drink.id = drinkID
        drink.drinkName = input.drinkName
        drink.drinkType = input.drinkType
        drink.category = input.category
        drink.sweetnessLevel = input.sweetnessLevel
        drink.bitternessLevel = input.bitternessLevel
        drink.personalRating = input.personalRating
        drink.tastingNotes = input.tastingNotes
        drink.year = input.year
        drink.createdAt = now
        drink.updatedAt = now

        do {
            let photos = try makePhotoManagedObjects(for: input.photos, drinkID: drinkID, createdAt: now)

            for photo in photos {
                photo.drink = drink
                drink.addToPhotos(photo)
            }

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func makePhotoManagedObjects(
        for images: [UIImage],
        drinkID: UUID,
        createdAt: Date
    ) throws -> [DrinkPhoto] {
        guard !images.isEmpty else { return [] }

        let photoDirectoryURL = try makeDrinkPhotoDirectory(drinkID: drinkID)
        var photoObjects: [DrinkPhoto] = []

        for (index, image) in images.enumerated() {
            let photoID = UUID()
            let fileURL = photoDirectoryURL.appendingPathComponent("\(photoID.uuidString).jpg", isDirectory: false)

            guard let imageData = image.jpegData(compressionQuality: 0.85) else {
                throw DrinkPersistenceError.photoEncodingFailed
            }

            try imageData.write(to: fileURL, options: .atomic)

            let photo = DrinkPhoto(context: context)
            photo.id = photoID
            photo.displayOrder = Int16(index)
            photo.createdAt = createdAt
            photo.filePath = fileURL.path
            photoObjects.append(photo)
        }

        return photoObjects
    }

    private func makeDrinkPhotoDirectory(drinkID: UUID) throws -> URL {
        let photosRootDirectoryURL = try documentsDirectoryURLProvider()
            .appendingPathComponent("DrinkPhotos", isDirectory: true)
        try fileManager.createDirectory(at: photosRootDirectoryURL, withIntermediateDirectories: true, attributes: nil)

        let drinkDirectoryURL = photosRootDirectoryURL.appendingPathComponent(drinkID.uuidString, isDirectory: true)
        try fileManager.createDirectory(at: drinkDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        return drinkDirectoryURL
    }
}

enum DrinkPersistenceError: Error {
    case photoEncodingFailed
}
