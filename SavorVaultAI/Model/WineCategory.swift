import Foundation

enum WineCategory: String, CaseIterable {
    case redWine = "red_wine"
    case whiteWine = "white_wine"
    case roseWine = "rose_wine"
    case sparklingWine = "sparkling_wine"
    case fortifiedWine = "fortified_wine"

    var displayName: String {
        switch self {
        case .redWine: return "Red Wine"
        case .whiteWine: return "White Wine"
        case .roseWine: return "Rosé Wine"
        case .sparklingWine: return "Sparkling Wine"
        case .fortifiedWine: return "Fortified Wine"
        }
    }
}
