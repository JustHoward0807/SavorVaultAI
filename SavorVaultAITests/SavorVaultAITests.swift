//
//  SavorVaultAITests.swift
//  SavorVaultAITests
//
//  Created by Lung-Hao Tung on 3/22/26.
//

import CoreData
import Testing
import UIKit
@testable import SavorVaultAI

@MainActor
struct SavorVaultAITests {

    @Test
    func saveDrinkPersistsDrinkAndPhotoFile() async throws {
        let persistentContainer = try await makeInMemoryPersistentContainer()
        let temporaryRootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryRootURL, withIntermediateDirectories: true)

        let persistenceService = DrinkPersistenceService(
            context: persistentContainer.viewContext,
            documentsDirectoryURLProvider: { temporaryRootURL }
        )
        let viewModel = AddDrinkViewModel(persistenceService: persistenceService)

        try viewModel.saveDrink(
            AddDrinkFormInput(
                drinkName: "Test Cabernet",
                drinkType: "Wine",
                category: WineCategory.redWine.rawValue,
                sweetnessLevel: 4,
                bitternessLevel: 1,
                personalRating: 5,
                tastingNotes: "Dark cherry and oak.",
                year: "2021",
                photos: [makeTestImage()]
            )
        )

        let drinkFetchRequest = Drink.fetchRequest()
        let drinks = try persistentContainer.viewContext.fetch(drinkFetchRequest)
        #expect(drinks.count == 1)

        guard let drink = drinks.first else {
            Issue.record("Expected one saved Drink record.")
            return
        }

        #expect(drink.drinkName == "Test Cabernet")
        #expect(drink.drinkType == "Wine")
        #expect(drink.category == WineCategory.redWine.rawValue)
        #expect(drink.sweetnessLevel == 4)
        #expect(drink.bitternessLevel == 1)
        #expect(drink.personalRating == 5)
        #expect(drink.tastingNotes == "Dark cherry and oak.")
        #expect(drink.year == "2021")

        let photoSet = drink.value(forKey: "photos") as? NSSet
        #expect(photoSet?.count == 1)

        guard let photo = photoSet?.allObjects.first as? DrinkPhoto else {
            Issue.record("Expected one related DrinkPhoto record.")
            return
        }

        let filePath = photo.filePath
        #expect(filePath != nil)

        guard let filePath else {
            Issue.record("Expected persisted file path for saved photo.")
            return
        }

        #expect(filePath.hasPrefix(temporaryRootURL.path))
        #expect(FileManager.default.fileExists(atPath: filePath))
    }

    @Test
    func saveDrinkRejectsEmptyName() {
        let viewModel = AddDrinkViewModel(persistenceService: nil)
        let input = AddDrinkFormInput(
            drinkName: "   ",
            drinkType: "Beer",
            category: BeerCategory.ipa.rawValue,
            sweetnessLevel: 2,
            bitternessLevel: 2,
            personalRating: 0,
            tastingNotes: nil,
            year: "Unknown",
            photos: [makeTestImage()]
        )

        #expect(throws: AddDrinkSaveError.drinkNameRequired) {
            try viewModel.saveDrink(input)
        }
    }

    @Test
    func viewModelNormalizesFormValues() {
        let viewModel = AddDrinkViewModel(persistenceService: nil)

        #expect(
            viewModel.normalizedCategoryValue(
                selectedWineCategory: .redWine,
                selectedBeerCategory: nil
            ) == WineCategory.redWine.rawValue
        )
        #expect(
            viewModel.normalizedCategoryValue(
                selectedWineCategory: nil,
                selectedBeerCategory: .ipa
            ) == BeerCategory.ipa.rawValue
        )
        #expect(viewModel.normalizedTastingNotes("   ") == nil)
        #expect(viewModel.normalizedTastingNotes(" Berry finish ") == "Berry finish")
        #expect(viewModel.normalizedYearValue(nil) == "Unknown")
        #expect(viewModel.normalizedYearValue("Select Year") == "Unknown")
        #expect(viewModel.normalizedYearValue("2020") == "2020")
    }

    private func makeInMemoryPersistentContainer() async throws -> NSPersistentContainer {
        guard let modelURL = Bundle(for: AppDelegate.self).url(forResource: "SavorVaultAI", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw TestError.modelLoadFailed
        }

        let container = NSPersistentContainer(name: "SavorVaultAI", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError {
            throw loadError
        }

        return container
    }

    private func makeTestImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 16, height: 16))
        return renderer.image { context in
            UIColor.systemRed.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 16, height: 16))
        }
    }

    enum TestError: Error {
        case modelLoadFailed
    }
}
