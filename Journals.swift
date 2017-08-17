//
//  Journals.swift
//  ProJournal
//
//  Created by hanif on 4/8/17.
//

import Foundation

class Journals : RetrievableProtocol {
    public static let instance:Journals = Journals()
    
    private var journalItems:[JournalItem]
    public var count:Int {
        return journalItems.count
    }
    
    init() {
        journalItems = []
    }
    
    public func setJournalItems(items:[JournalItem]) {
        self.journalItems=items
    }
    
    public func add(item:JournalItem, at:Int = -1) {
        if at == -1 {
            journalItems.append(item)
        } else {
            journalItems.insert(item, at: at)
        }
    }
    
    public func get(index:IndexPath?)->JournalItem? {
        return journalItems[(index?.row)!]
    }
    
    public func get(_ index:Int)->JournalItem? {
        if journalItems.count >= index || index < 0 {
            return nil
        }
        return journalItems[index]
    }
    
    public func filter(_ query:String?)->[JournalItem] {
        return query == nil ? [] : journalItems.filter({$0.name.lowercased().contains(query!.lowercased())})
    }
}
