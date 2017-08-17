//
//  Utilitities.swift
//  ProJournal
//
//  Created by admin on 17/8/17.
//  Copyright © 2017 ipa. All rights reserved.
//

import Foundation

public class Utilities {
    
    static func generateRandomColour()->Int32 {
        let red = arc4random_uniform(255),
        green = arc4random_uniform(255),
        blue = arc4random_uniform(255)
        
        let finalColour = (red << 16) | (green << 8) | blue
        return Int32(finalColour)
    }
}
