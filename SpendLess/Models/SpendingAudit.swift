//
//  SpendingAudit.swift
//  SpendLess
//
//  Spending Audit models for inventory-based category audits
//

import Foundation
import SwiftData

// MARK: - Spending Audit Model

@Model
final class SpendingAudit {
    var id: UUID
    var categoryRaw: String // AuditCategory raw value
    var customCategoryName: String? // if "Other"
    var createdAt: Date
    
    // Reality check responses (optional)
    var regularlyUsedRangeRaw: String? // UsageRange raw value
    var lastFinishedProductRaw: String? // FinishFrequency raw value
    var duplicateEstimateRaw: String? // DuplicateRange raw value
    
    // User-adjustable
    var yearsAccumulating: Int
    
    // Relationship to items
    @Relationship(deleteRule: .cascade, inverse: \AuditItem.audit)
    var items: [AuditItem]
    
    init(
        id: UUID = UUID(),
        category: AuditCategory,
        customCategoryName: String? = nil,
        createdAt: Date = Date(),
        yearsAccumulating: Int = 3
    ) {
        self.id = id
        self.categoryRaw = category.rawValue
        self.customCategoryName = customCategoryName
        self.createdAt = createdAt
        self.yearsAccumulating = yearsAccumulating
        self.items = []
    }
    
    // MARK: - Computed Properties
    
    var category: AuditCategory {
        get { AuditCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    
    var regularlyUsedRange: UsageRange? {
        get { regularlyUsedRangeRaw.flatMap { UsageRange(rawValue: $0) } }
        set { regularlyUsedRangeRaw = newValue?.rawValue }
    }
    
    var lastFinishedProduct: FinishFrequency? {
        get { lastFinishedProductRaw.flatMap { FinishFrequency(rawValue: $0) } }
        set { lastFinishedProductRaw = newValue?.rawValue }
    }
    
    var duplicateEstimate: DuplicateRange? {
        get { duplicateEstimateRaw.flatMap { DuplicateRange(rawValue: $0) } }
        set { duplicateEstimateRaw = newValue?.rawValue }
    }
    
    var totalValue: Decimal {
        items.reduce(0) { $0 + $1.totalValue }
    }
    
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var annualizedValue: Decimal {
        guard yearsAccumulating > 0 else { return totalValue }
        return totalValue / Decimal(yearsAccumulating)
    }
    
    var monthlyValue: Decimal {
        annualizedValue / 12
    }
    
    var displayName: String {
        if category == .other, let customName = customCategoryName, !customName.isEmpty {
            return customName
        }
        return category.displayName
    }
    
    /// Calculate life energy hours if hourly wage is provided
    func lifeEnergyHours(hourlyWage: Decimal) -> Decimal? {
        guard hourlyWage > 0 else { return nil }
        return totalValue / hourlyWage
    }
    
    /// Estimated usage percentage based on reality check
    var estimatedUsagePercentage: Int? {
        guard let usageRange = regularlyUsedRange else { return nil }
        let totalItems = totalItemCount
        guard totalItems > 0 else { return nil }
        
        let usedItems: Int
        switch usageRange {
        case .fewItems: usedItems = min(3, totalItems)
        case .someItems: usedItems = min(8, totalItems)
        case .manyItems: usedItems = min(15, totalItems)
        case .mostItems: usedItems = Int(Double(totalItems) * 0.8)
        }
        
        return (usedItems * 100) / totalItems
    }
}

// MARK: - Audit Item Model

@Model
final class AuditItem {
    var id: UUID
    var audit: SpendingAudit?
    var subcategory: String // "Face", "Eyes", etc.
    var name: String // "Foundation", "Mascara", etc.
    var quantity: Int
    var averagePrice: Decimal
    var isCustom: Bool // user-added item
    
    init(
        id: UUID = UUID(),
        subcategory: String,
        name: String,
        quantity: Int = 0,
        averagePrice: Decimal = 0,
        isCustom: Bool = false
    ) {
        self.id = id
        self.subcategory = subcategory
        self.name = name
        self.quantity = quantity
        self.averagePrice = averagePrice
        self.isCustom = isCustom
    }
    
    var totalValue: Decimal {
        Decimal(quantity) * averagePrice
    }
    
    var hasValue: Bool {
        quantity > 0 && averagePrice > 0
    }
}

// MARK: - Audit Category Enum

enum AuditCategory: String, CaseIterable, Codable, Identifiable {
    case makeup = "Makeup"
    case skincare = "Skincare"
    case clothing = "Clothing"
    case shoes = "Shoes"
    case bagsAccessories = "Bags & Accessories"
    case hobbies = "Hobbies"
    case other = "Other"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .makeup: return "💄"
        case .skincare: return "🧴"
        case .clothing: return "👕"
        case .shoes: return "👟"
        case .bagsAccessories: return "👜"
        case .hobbies: return "🎯"
        case .other: return "✨"
        }
    }
    
    var subcategories: [AuditSubcategory] {
        switch self {
        case .makeup:
            return AuditCategoryPresets.makeup
        case .skincare:
            return AuditCategoryPresets.skincare
        case .clothing:
            return AuditCategoryPresets.clothing
        case .shoes:
            return AuditCategoryPresets.shoes
        case .bagsAccessories:
            return AuditCategoryPresets.bagsAccessories
        case .hobbies:
            return AuditCategoryPresets.hobbies
        case .other:
            return [] // User defines custom subcategories
        }
    }
}

// MARK: - Audit Subcategory

struct AuditSubcategory: Identifiable, Hashable {
    let id = UUID()
    let name: String // "Face", "Eyes", etc.
    let items: [String] // ["Foundation", "Concealer", etc.]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: AuditSubcategory, rhs: AuditSubcategory) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Usage Range Enum

enum UsageRange: String, CaseIterable, Codable, Identifiable {
    case fewItems = "1-5"
    case someItems = "6-10"
    case manyItems = "11-20"
    case mostItems = "Most"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
}

// MARK: - Finish Frequency Enum

enum FinishFrequency: String, CaseIterable, Codable, Identifiable {
    case recently = "Recently"
    case aWhileAgo = "A while ago"
    case cantRemember = "Can't remember"
    case buyBeforeRunOut = "Buy before running out"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .recently: return "Recently (past month)"
        case .aWhileAgo: return "A while ago"
        case .cantRemember: return "Can't remember"
        case .buyBeforeRunOut: return "I usually buy before I run out"
        }
    }
}

// MARK: - Duplicate Range Enum

enum DuplicateRange: String, CaseIterable, Codable, Identifiable {
    case few = "Few"
    case some = "Some"
    case many = "Many"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
}

// MARK: - Category Presets

struct AuditCategoryPresets {
    
    static let makeup: [AuditSubcategory] = [
        AuditSubcategory(name: "Face", items: [
            "Foundation",
            "Concealer",
            "Powder",
            "Blush",
            "Bronzer",
            "Highlighter",
            "Primer",
            "Setting Spray"
        ]),
        AuditSubcategory(name: "Eyes", items: [
            "Mascara",
            "Eyeliner",
            "Eyeshadow Palettes",
            "Eyeshadow Singles",
            "Brow Products",
            "False Lashes"
        ]),
        AuditSubcategory(name: "Lips", items: [
            "Lipstick",
            "Lip Gloss",
            "Lip Liner",
            "Lip Balm/Treatment"
        ])
    ]
    
    static let skincare: [AuditSubcategory] = [
        AuditSubcategory(name: "Cleansing", items: [
            "Cleanser",
            "Makeup Remover",
            "Exfoliator",
            "Micellar Water"
        ]),
        AuditSubcategory(name: "Treatment", items: [
            "Serums",
            "Toner/Essence",
            "Eye Cream",
            "Face Masks",
            "Spot Treatment",
            "Retinol/Actives"
        ]),
        AuditSubcategory(name: "Moisturizing", items: [
            "Moisturizer (Day)",
            "Night Cream",
            "Facial Oil",
            "Sunscreen",
            "Lip Treatment"
        ])
    ]
    
    static let clothing: [AuditSubcategory] = [
        AuditSubcategory(name: "Tops", items: [
            "T-shirts",
            "Blouses/Dress Shirts",
            "Sweaters",
            "Tank Tops",
            "Hoodies/Sweatshirts"
        ]),
        AuditSubcategory(name: "Bottoms", items: [
            "Jeans",
            "Pants/Trousers",
            "Shorts",
            "Skirts",
            "Leggings"
        ]),
        AuditSubcategory(name: "Dresses & Jumpsuits", items: [
            "Casual Dresses",
            "Formal Dresses",
            "Jumpsuits/Rompers"
        ]),
        AuditSubcategory(name: "Outerwear", items: [
            "Jackets",
            "Coats",
            "Blazers",
            "Vests"
        ]),
        AuditSubcategory(name: "Activewear", items: [
            "Sports Bras",
            "Workout Tops",
            "Workout Bottoms"
        ])
    ]
    
    static let shoes: [AuditSubcategory] = [
        AuditSubcategory(name: "Casual", items: [
            "Sneakers",
            "Flats",
            "Sandals",
            "Loafers"
        ]),
        AuditSubcategory(name: "Formal", items: [
            "Heels",
            "Dress Shoes",
            "Oxfords"
        ]),
        AuditSubcategory(name: "Athletic", items: [
            "Running Shoes",
            "Training Shoes",
            "Hiking Boots"
        ]),
        AuditSubcategory(name: "Seasonal", items: [
            "Boots",
            "Rain Boots",
            "Slippers"
        ])
    ]
    
    static let bagsAccessories: [AuditSubcategory] = [
        AuditSubcategory(name: "Bags", items: [
            "Handbags",
            "Totes",
            "Crossbody Bags",
            "Backpacks",
            "Clutches"
        ]),
        AuditSubcategory(name: "Accessories", items: [
            "Scarves",
            "Hats",
            "Belts",
            "Sunglasses",
            "Jewelry (estimate)"
        ])
    ]
    
    static let hobbies: [AuditSubcategory] = [
        AuditSubcategory(name: "Gaming", items: [
            "Consoles",
            "Handheld Devices",
            "Controllers",
            "Headsets",
            "Video Games (physical)",
            "Video Games (digital, estimate)",
            "In-Game Purchases (estimate lifetime)",
            "Gaming Subscriptions"
        ]),
        AuditSubcategory(name: "Board Games", items: [
            "Board Games",
            "Card Games",
            "Tabletop RPGs",
            "Expansions & Add-ons",
            "Dice, Sleeves & Accessories"
        ]),
        AuditSubcategory(name: "Collectibles", items: [
            "Trading Cards",
            "Figures & Statues",
            "Vinyl/Records",
            "Comics & Manga",
            "Memorabilia",
            "Limited Editions"
        ]),
        AuditSubcategory(name: "Hardware", items: [
            "Computers & Laptops",
            "Tablets",
            "Cameras & Lenses",
            "Audio Equipment",
            "Musical Instruments",
            "Tools & Equipment"
        ])
    ]
}

