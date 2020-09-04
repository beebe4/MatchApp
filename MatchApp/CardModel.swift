//
//  CardModel.swift
//  MatchApp
//
//  Created by administrator on 8/25/20.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
    
        // Declare empty array
        var generatedCards = [Card]()
        var randomNumberArray = [Int]()
        
        // Randomly generate 8 pairs of cards
        while generatedCards.count < 16 {
            
            // Generate a random number
            let rand = Int.random(in: 1...13)
            
            if !randomNumberArray.contains(rand) {
                
                // Add rand to Array for tracking
                randomNumberArray += [rand]
                
                // Create 2 new card objects
                let card1 = Card()
                let card2 = Card()
            
                // Set their image names
                card1.imageName = "card\(rand)"
                card2.imageName = "card\(rand)"
            
                // Add them to the array
                generatedCards += [card1,card2]
            }
        }
        
        // Randomize the cards within the array
        generatedCards.shuffle()
        
        // Return the array
        return generatedCards
        
    }
}
