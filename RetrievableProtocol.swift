//
//  RetrievableProtocol.swift
//  ProJournal
//
//  Created by hanif on 17/8/17.
//  Copyright © 2017 ipa. All rights reserved.
//

import Foundation

public protocol RetrievableProtocol {
    associatedtype T
    
    func get(_ index:Int)->T?
    func get(index:IndexPath?)->T?
    var count:Int {
        get
    }
}
