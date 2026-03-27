import Foundation

enum BeerCategory: String, CaseIterable {
    case lager = "lager"
    case paleAle = "pale_ale"
    case ipa = "ipa"
    case wheatBeer = "wheat_beer"
    case porter = "porter"
    case stout = "stout"
    case sourBeer = "sour_beer"
    case belgianStyle = "belgian_style"
    case amberBrownAle = "amber_brown_ale"
    case pilsner = "pilsner"
    case specialtyStrongBeer = "specialty_strong_beer"

    var displayName: String {
        switch self {
        case .lager: return "Lager"
        case .paleAle: return "Pale Ale"
        case .ipa: return "IPA"
        case .wheatBeer: return "Wheat Beer"
        case .porter: return "Porter"
        case .stout: return "Stout"
        case .sourBeer: return "Sour Beer"
        case .belgianStyle: return "Belgian Style"
        case .amberBrownAle: return "Amber / Brown Ale"
        case .pilsner: return "Pilsner"
        case .specialtyStrongBeer: return "Specialty / Strong Beer"
        }
    }
}
