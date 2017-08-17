//
//  JournalItem.swift
//  ProJournal
//
//  Created by hanif on 4/8/17.
//

import Foundation

class JournalItem {
    var name:String
    var colour:Int32
    var dateCreated:Date
    var entries:[JournalEntry]
    
    init(name:String, colour:Int32, dateCreated:Date) {
        self.name=name;
        self.colour=colour
        self.dateCreated=dateCreated
        self.entries=[]
    }
    
    public func addEntry(entry:JournalEntry?) {
        guard let journalEntry = entry else {
            return
        }
        entries.append(journalEntry)
    }
}
