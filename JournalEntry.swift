//
//  JournalEntry.swift
//  ProJournal
//
//  Created by hanif on 10/8/17.
//

import Foundation

class JournalEntry {
    var dateCreated:Date
    var contents:String
    var oldEntry:JournalEntry?
    
    init(dateCreated:Date, contents:String) {
        self.dateCreated=dateCreated
        self.contents=contents
    }
}
