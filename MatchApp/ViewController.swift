//
//  ViewController.swift
//  MatchApp
//
//  Created by administrator on 8/25/20.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    @IBOutlet weak var timerLabel: UILabel!
    
    let model = CardModel()
    var cardsArray = [Card]()
    
    var timer:Timer?
    var milliseconds:Int = 30 * 1000
 
    var firstFlippedCardIndex:IndexPath?
    
    var soundPlayer = SoundManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cardsArray = model.getCards()
        
        // Set the viewController as the datasource and delegate of the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Play Shuffle Sound
        soundPlayer.playSound(effect: .shuffle)
    }

    // MARK: - Timer Methods
    
    @objc func timerFired() {
        
        // Decrement counter
        milliseconds -= 1
        
        // Update the label
        let seconds:Double = Double(milliseconds)/1000.0
        timerLabel.text = String(format: "Time Remaining: %.2f", seconds)
        
        // Stop the timer if it has reached zero
        if milliseconds == 0 {
            timerLabel.textColor = UIColor.red
            timer?.invalidate()
            
            // Check if the user has cleared all the pairs
            checkForGameEnd()
        }
    }
    
    // MARK: - Collection View Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return number of cards
        return cardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
                      
        // Return cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Configure the cell
        let cardCell = cell as? CardCollectionViewCell
        cardCell?.configureCell(card: cardsArray[indexPath.row])
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Check if time has expired and exit if so
        if milliseconds <= 0 {
            return
        }
        
        // Get a reference to the cell
        let selectedCell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        
        // Only do stuff with unflipped cards
        if selectedCell?.card?.isFlipped == false && selectedCell?.card?.isMatched == false {
            // Flip the selected cell
            selectedCell?.flipUp()

            // Play flip sound
            soundPlayer.playSound(effect: .flip)

            
            if firstFlippedCardIndex == nil {

                // This is the first card flipped over
                firstFlippedCardIndex = indexPath

            } else {
                
                // Check if the two cards match
                checkForMatch(indexPath)

            }
        }
    }
    
    // MARK: - Game Logic Methods
    
    func checkForMatch(_ secondFlippedCardIndex:IndexPath) {
        // Get the two card objects
        let cardOne = cardsArray[firstFlippedCardIndex!.row]
        let cardTwo = cardsArray[secondFlippedCardIndex.row]
        
        // Get the two collection view cells that represent cards 1 & 2
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        if cardOne.imageName == cardTwo.imageName {
            // We have a match!
            
            // Set the status to Matched
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            // remove the cards
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            // Play match sound
            soundPlayer.playSound(effect: .match)
            
            // Was that the last pair?
            checkForGameEnd()
        }
        else {
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            // Cards don't match so flip them back over
            cardOneCell?.flipDown(delay:0.75)
            cardTwoCell?.flipDown(delay:0.75)
            
            // Play nomatch sound
            soundPlayer.playSound(effect: .nomatch)
        }
        
        // Set firstCell to nil
        firstFlippedCardIndex = nil
    }

    func checkForGameEnd() {
        
        // Check if there are any cards that are unmatched
        // Assume user has won and then loop through all cards to see if all of them are matched
        var hasWon = true
        
        for card in cardsArray {
            
            if card.isMatched == false {
                // We've found a card that is unmatched
                hasWon = false
                break
            }
        }
        
        if hasWon {
            // User has won
            showAlert(title: "Congratulations!", message: "You've won the game!")
        }
        else {
            // User hasn't won yet, check if there's any time left
            if milliseconds <= 0 {
                showAlert(title: "Times Up", message: "You lost. Better luck next time.")
            }
        }
    }
    
    func showAlert(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a button for the user to dismiss it
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
}


