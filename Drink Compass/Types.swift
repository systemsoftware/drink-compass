import SwiftUI

enum FindType: String, CaseIterable, Identifiable {
    case liquorStore
    case pharmacy
    case groceryStore
    case gasStation
    case restaurant
    case cafe
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .liquorStore: return "Liquor Store"
        case .pharmacy: return "Pharmacy"
        case .groceryStore: return "Grocery Store"
        case .gasStation: return "Gas Station"
        case .restaurant: return "Restaurant"
        case .cafe: return "Cafe"
        }
    }
    
    var searchTerms: [String] {
        switch self {
        case .liquorStore: return ["Liquor Store", "Liquor", "Wine & Spirits", "Beer Wine Liquor"]
        case .pharmacy: return ["Pharmacy", "Drug Store", "Chemist"]
        case .groceryStore: return ["Grocery Store", "Supermarket", "Food Market"]
        case .gasStation: return ["Gas Station", "Petrol Station", "Fuel Station"]
        case .restaurant: return ["Restaurant", "Diner", "Eatery"]
        case .cafe: return ["Cafe", "Coffee Shop", "Coffee House"]
        }
    }
}
