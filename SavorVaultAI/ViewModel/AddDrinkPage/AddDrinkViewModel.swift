//
//  AddDrinkViewModel.swift
//  SavorVaultAI
//

import UIKit

struct AddDrinkFormInput {
    let drinkName: String
    let drinkType: String?
    let category: String?
    let sweetnessLevel: Int16
    let bitternessLevel: Int16
    let personalRating: Int16
    let tastingNotes: String?
    let year: String
    let photos: [UIImage]
}

enum AddDrinkSaveError: LocalizedError {
    case drinkNameRequired
    case persistenceUnavailable
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .drinkNameRequired:
            return "Enter a drink name before saving."
        case .persistenceUnavailable:
            return "The app could not access the local database."
        case .saveFailed:
            return "The drink could not be saved. Please try again."
        }
    }
}

protocol DrinkPersisting {
    func saveDrink(_ input: AddDrinkFormInput) throws
}

final class AddDrinkViewModel {

    private let persistenceService: DrinkPersisting?

    init(persistenceService: DrinkPersisting?) {
        self.persistenceService = persistenceService
    }

    func saveDrink(_ input: AddDrinkFormInput) throws {
        guard !input.drinkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AddDrinkSaveError.drinkNameRequired
        }

        guard let persistenceService else {
            throw AddDrinkSaveError.persistenceUnavailable
        }

        do {
            try persistenceService.saveDrink(input)
        } catch {
            throw AddDrinkSaveError.saveFailed
        }
    }

    func normalizedCategoryValue(
        selectedWineCategory: WineCategory?,
        selectedBeerCategory: BeerCategory?
    ) -> String? {
        if let selectedWineCategory {
            return selectedWineCategory.rawValue
        }

        if let selectedBeerCategory {
            return selectedBeerCategory.rawValue
        }

        return nil
    }

    func normalizedTastingNotes(_ notes: String?) -> String? {
        let normalizedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return normalizedNotes.isEmpty ? nil : normalizedNotes
    }

    func normalizedYearValue(_ yearText: String?) -> String {
        guard let yearText = yearText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !yearText.isEmpty,
              yearText != "Select Year" else {
            return "Unknown"
        }

        return yearText
    }
}
