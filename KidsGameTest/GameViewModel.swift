//
//  GameViewModel.swift
//  KidsGameTest
//
//  Created by Lobanov Viktor on 22.04.2026.
//

import Foundation

class GameViewModel {
    
    // Все возможные фрукты (согласно твоим ассетам)
    private let allItems = [
        FoodItem(id: 0, name: "Apple", targetImage: "Apple", basketImage: "Apple_circle"),
        FoodItem(id: 1, name: "Banana", targetImage: "Banana", basketImage: "Banana_circle"),
        FoodItem(id: 2, name: "Kiwi", targetImage: "Kiwi", basketImage: "Kiwi_circle"),
        FoodItem(id: 3, name: "Raspberry", targetImage: "Raspberry", basketImage: "Raspberry_circle"),
        FoodItem(id: 4, name: "Strawberry", targetImage: "Strawberry", basketImage: "Strawberry_circle")
    ]
    
    // Состояние игры
    private(set) var targets: [FoodItem] = []      // 3 фрукта сверху
    private(set) var basketItems: [FoodItem] = []  // 5 фруктов в корзине
    private(set) var guessedIds: Set<Int> = []     // Сюда сохраняем угаданные ID
    
    var isLevelComplete: Bool {
            return guessedIds.count == targets.count && targets.count > 0
        }
    
    // Callback для обновления экрана
    var onUpdate: (() -> Void)?

    init() {
        generateLevel()
    }
    
    func generateLevel() {
        guessedIds.removeAll()
        
        // 1. Выбираем 3 случайных фрукта для целей
        targets = Array(allItems.shuffled().prefix(3))
        
        // 2. В корзине должны быть эти 3 + еще 2 случайных (всего 5)
        let extras = allItems.filter { item in !targets.contains(where: { $0.id == item.id }) }
        basketItems = (targets + extras.shuffled().prefix(2)).shuffled()
        
        onUpdate?()
    }
    
    // Проверка: попал ли игрок нужной ягодой в нужную цель
    func checkMatch(foodId: Int, targetIndex: Int) -> Bool {
        // Безопасно проверяем индекс
        guard targetIndex < targets.count else { return false }
        let target = targets[targetIndex]
        
        // Если ID совпали
        if target.id == foodId {
            // Если еще не угадывали — добавляем в Set
            if !guessedIds.contains(foodId) {
                guessedIds.insert(foodId)
                return true // Это "свежая" победа
            }
            return true // Уже было угадано, но место верное
        }
        
        return false // Место вообще не то (котик будет грустить)
    }
    
}
