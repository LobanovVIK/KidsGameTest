//
//  FoodItem.swift
//  KidsGameTest
//
//  Created by Lobanov Viktor on 22.04.2026.
//

import Foundation

struct FoodItem: Identifiable, Equatable {
    let id: Int
    let name: String
    let targetImage: String  // Имя из Assets для верха (shape/guessed)
    let basketImage: String  // Имя из Assets для корзинки (circle)
    
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id
    }
}
