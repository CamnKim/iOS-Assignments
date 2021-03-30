//
//  ViewController.swift
//  MatchEmScene
//
//  Created by Cameron Kim on 3/29/21.
//

import UIKit

class GameSceneViewController: UIViewController {
    // MARK: - ==== Config Properties ====
    // Min and max width and height for the rectangles
    private let rectSizeMin: CGFloat =  50.0
    private let rectSizeMax: CGFloat = 150.0
    
    // Turns on random alpha values for rectangles
    private let randomAlpha = false
    
    // duration of rectangle fade animation
    private let fadeDuration: TimeInterval = 0.8
    
    // Rectangle creation interval
    private let newRectInterval: TimeInterval = 1.0
    
    // Game duration
    private let gameDuration: TimeInterval = 12.0
    
    
    
    //MARK: - ==== Internal Properties ====
    // A game is in progress
    private var gameInProgress = false
    
    // Keep track of all rectangles created
    private var rectangles: [UIButton: UIButton] = [:]
    
    // Rectangle creation, so the timer can be stopped
    private var newRectTimer:Timer?
    
    // Game timer
    private var gameTimer: Timer?
    
    // Counters with property observers
    private var rectanglesCreated: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo }
    }
    private var rectanglesTouched: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo }
    }
    
    // Game Info Label
    @IBOutlet weak var gameInfoLabel: UILabel!
    
    
    // Game Info
    private var gameInfo: String {
        let labelText = String(format: "Time: %2.1f Pairs: %2d Matched: %2d", gameTimeRemaining, rectanglesCreated, rectanglesTouched)
        return labelText
    }
    
    // Init the time remaining
    private lazy var gameTimeRemaining = gameDuration {
        didSet { gameInfoLabel?.text = gameInfo}
    }
    
    // First, stores first highlighted button
    private var first: UIButton?
    
    
    
    // MARK: - ==== View Controller Methods ====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        // CALL SUPER IN THESE METHODS
        super.viewWillAppear(animated)
        
        // Create a single rectangle
        startGameRunning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc private func handleTouch(sender: UIButton) {
        if !gameInProgress {
            return
        }
        
        // Check if first touch
        if first == nil {
            // First touch
            first = sender
            
            // Add emoji to rectangle
            sender.setTitle("⭐️", for: .normal)
        }
        else {
            // Second touch
            if sender == rectangles[first!] {
                // Pair is found
                // Add emoji to rectangle
                sender.setTitle("⭐️", for: .normal)
                // Change pair's alpha to 0
                removeRectangle(rectangle: sender)
                removeRectangle(rectangle: first!)
                first = nil
                
                // Increment rectanglesTouched
                rectanglesTouched += 1
            }
            else {
                // NOT pair
                first?.setTitle("", for: .normal)
                first = nil
            }
        }
    }
}


// MARK: - ==== Rectangle Methods ====
extension GameSceneViewController {
    private func createRectangle() {
        // Get random values common for the pair
        let randSize = Utility.getRandomSize(fromMin: rectSizeMin, throughMax: rectSizeMax)
        let randColor = Utility.getRandomColor(randomAlpha: randomAlpha)
        
        // Get random location for each rectangle
        let randLocationOne = Utility.getRandomLocation(size: randSize, screenSize: view.bounds.size)
        let randLocationTwo = Utility.getRandomLocation(size: randSize, screenSize: view.bounds.size)
        
        // Create both frames
        let randomFrameOne = CGRect(origin: randLocationOne, size: randSize)
        let randomFrameTwo = CGRect(origin: randLocationTwo, size: randSize)
        
        // Create both rectangle
        let rectangleOne = UIButton(frame: randomFrameOne)
        let rectangleTwo = UIButton(frame: randomFrameTwo)
        
        // Increment rectanglesCreated
        rectanglesCreated += 1
        
        // Save rectangle pairs
        rectangles[rectangleOne] = rectangleTwo
        rectangles[rectangleTwo] = rectangleOne
        
        // Button/Rectangle setup 1
        rectangleOne.backgroundColor = randColor
        rectangleOne.setTitle("", for: .normal)
        rectangleOne.setTitleColor(.black, for: .normal)
        rectangleOne.titleLabel?.font = .systemFont(ofSize: 50)
        rectangleOne.showsTouchWhenHighlighted = true
        
        // Button/Rectangle setup 2
        rectangleTwo.backgroundColor = randColor
        rectangleTwo.setTitle("", for: .normal)
        rectangleTwo.setTitleColor(.black, for: .normal)
        rectangleTwo.titleLabel?.font = .systemFont(ofSize: 50)
        rectangleTwo.showsTouchWhenHighlighted = true
        
        // Target/action to set up connect of button to the VC
        rectangleOne.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        rectangleTwo.addTarget(self, action: #selector(self.handleTouch(sender:)), for: .touchUpInside)
        
        // Make rectangle visible
        self.view.addSubview(rectangleOne)
        self.view.addSubview(rectangleTwo)
        
        // Move label to the front
        view.bringSubviewToFront(gameInfoLabel!)
        
        // Decrement time remaining
        gameTimeRemaining -= newRectInterval
    }
    
    // Remove rectangle
    func removeRectangle(rectangle: UIButton) {
        // Rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: fadeDuration, curve: .linear, animations: nil)
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
    }
    
    // Clear rectangles
    func removeSavedRectangles() {
        // Remove all rectangles from superview
        for (rectangleKey, _) in rectangles {
            rectangleKey.removeFromSuperview()
        }
        
        // Clear rectangles array
        rectangles.removeAll()
    }
}


//MARK: - ==== Timer Functions ====
extension GameSceneViewController {
    private func startGameRunning() {
        // Clear all rectangles from prev game
        removeSavedRectangles()
        
        // Timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval, repeats: true, block: { _ in self.createRectangle() })
        
        // Timer to end game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration, repeats: false, block: { _ in self.stopGameRunning() })
        
        // Start game
        gameInProgress = true
        
        // Init label styling
        gameInfoLabel.textColor = .black
        gameInfoLabel.backgroundColor = .clear
    }
    
    private func stopGameRunning() {
        // Stop timer
        if let timer = newRectTimer { timer.invalidate() }
        
        // Remove reference to timer obj
        self.newRectTimer = nil
        
        // Stop game
        gameInProgress = false
        
        // Update label after game is over
        gameTimeRemaining = 0.0
        gameInfoLabel?.text = gameInfo
        
        // Change label styling for game over
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
    }
}
