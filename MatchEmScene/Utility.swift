//
//  Utility.swift
//  MatchEmScene
//
//  Created by Cameron Kim on 3/29/21.
//

import UIKit

class Utility: NSObject {
    //MARK: - ==== Random Value Funcs ====
    // Random number between 0-1
    static func randomFloatZeroThroughOne() -> CGFloat {
        
        // Get random value
        let randomFloat = CGFloat.random(in: 0 ... 1.0)
        return randomFloat
    }
    
    // Random CGSize
    static func getRandomSize(fromMin min: CGFloat, throughMax max: CGFloat) -> CGSize {
        // Create random CGSize
        let randWidth = randomFloatZeroThroughOne() * (max - min) + min
        let randHeight = randomFloatZeroThroughOne() * (max - min) + min
        let randSize = CGSize(width: randWidth, height: randHeight)
        
        return randSize
    }
    
    // Random location
    static func getRandomLocation(size rectSize: CGSize, screenSize: CGSize) -> CGPoint {
        // Get screen dimensions
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Create random location/point
        let rectX = randomFloatZeroThroughOne() * (screenWidth - rectSize.width)
        let rectY = randomFloatZeroThroughOne() * (screenHeight - rectSize.height)
        let location = CGPoint(x: rectX, y: rectY)
        
        return location
    }
    
    // Random Color
    static func getRandomColor(randomAlpha: Bool) -> UIColor {
        // Get random values for rgb
        let randRed = randomFloatZeroThroughOne()
        let randGreen = randomFloatZeroThroughOne()
        let randBlue = randomFloatZeroThroughOne()
        
        // Transparency can be none or random
        var alpha:CGFloat = 1.0
        if randomAlpha {
            alpha = randomFloatZeroThroughOne()
        }
        
        return UIColor(red: randRed, green: randGreen, blue: randBlue, alpha: alpha)
    }
}
