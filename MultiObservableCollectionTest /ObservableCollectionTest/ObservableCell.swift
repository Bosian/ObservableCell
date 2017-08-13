//
//  ObservableCell.swift
//  MVVMTest
//
//  Created by 劉柏賢 on 2017/08/12.
//  Copyright © 2017年 劉柏賢. All rights reserved.
//

import UIKit

public class ObservableCell<TSection, TRow>: Collection {
    
    public typealias CellType = (section: TSection, row: ObservableCollection<TRow>)
    
    public private(set) var collection: ObservableCollection<CellType>
    
    public var collectionChanged = CollectionChange()
    
    private let insertSectionsAnimation: UITableViewRowAnimation
    private let deleteSectionsAnimation: UITableViewRowAnimation
    private let reloadSectionsAnimation: UITableViewRowAnimation
    
    public var startIndex: Int {
        return collection.startIndex
    }
    
    public var endIndex: Int {
        return collection.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return collection.index(after: i)
    }
    
    public var count: Int {
        return collection.count
    }
    
    public subscript(section: Int) -> CellType {
        get {
            return collection[section]
        }
        
        set {
            print("\(#function): section:\(section)")
            
            register(row: newValue.row)
            
            collection[section] = newValue
            notifyCollectionChanged(reloadSections: IndexSet(integer: section), reloadSectionsAnimation: reloadSectionsAnimation)
        }
    }
    
    public init(insertSectionsAnimation: UITableViewRowAnimation = .none, deleteSectionsAnimation: UITableViewRowAnimation = .none, reloadSectionsAnimation: UITableViewRowAnimation = .none) {
        collection = ObservableCollection<CellType>(section: 0)
        
        self.insertSectionsAnimation = insertSectionsAnimation
        self.deleteSectionsAnimation = deleteSectionsAnimation
        self.reloadSectionsAnimation = reloadSectionsAnimation
    }
    
    public func append(_ item: CellType)
    {
        let section = collection.count
        print("\(#function): section:\(section)")
        
        register(row: item.row)
        
        collection.append(item)
        notifyCollectionChanged(insertSections: IndexSet(integer: section), insertSectionsAnimation: insertSectionsAnimation)
    }
    
    public func append(contentOf items: [CellType])
    {
        for index in 0..<items.count
        {
            append(items[index])
        }
    }
    
    public func insert(_ item: CellType, at section: Int)
    {
        print("\(#function): section:\(section)")
        
        register(row: item.row)
        
        collection.insert(item, at: section)
        resetSection(collection: collection)
        notifyCollectionChanged(insertSections: IndexSet(integer: section), insertSectionsAnimation: insertSectionsAnimation)
    }
    
    public func remove(at section: Int)
    {
        print("\(#function): \(section)")

        collection.remove(at: section)
        resetSection(collection: collection)
        notifyCollectionChanged(deleteSections: IndexSet(integer: section), deleteSectionsAnimation: deleteSectionsAnimation)
    }
    
    public func removeAll()
    {
        collection.removeAll()
        notifyCollectionChanged(deleteRowsAnimation: deleteSectionsAnimation)
    }
    
    private func register(row: ObservableCollection<TRow>)
    {
        row.collectionChanged += CollectionChangeParameter(method: { [weak self] (args) in
            self?.notifyCollectionChanged(insertRows: args.insertRows,
                                          reloadRows: args.reloadRows,
                                          deleteRows: args.deleteRows,
                                          insertRowsAnimation: args.insertRowsAnimation,
                                          reloadRowsAnimation: args.reloadRowsAnimation,
                                          deleteRowsAnimation: args.deleteRowsAnimation)
        })
    }
    
    private func resetSection(collection: ObservableCollection<CellType>)
    {
        for section in 0..<collection.count
        {
            collection[section].row.section = section
        }
    }
    
    private func notifyCollectionChanged(insertRows: [IndexPath] = [], reloadRows: [IndexPath] = [], deleteRows: [IndexPath] = [],
                                         insertSections: IndexSet? = nil, reloadSections: IndexSet? = nil, deleteSections: IndexSet? = nil,
                                         insertRowsAnimation: UITableViewRowAnimation = .none, reloadRowsAnimation: UITableViewRowAnimation = .none, deleteRowsAnimation: UITableViewRowAnimation = .none,
                                         insertSectionsAnimation: UITableViewRowAnimation = .none, reloadSectionsAnimation: UITableViewRowAnimation = .none, deleteSectionsAnimation: UITableViewRowAnimation = .none
        )
    {
        let eventArgs = CollectionEventArgs(
            insertRows: insertRows, deleteRows: deleteRows, reloadRows: reloadRows,
            insertSections: insertSections, deleteSections: deleteSections, reloadSections: reloadSections,
            insertRowsAnimation: insertRowsAnimation, deleteRowsAnimation: deleteRowsAnimation, reloadRowsAnimation: reloadRowsAnimation,
            insertSectionsAnimation: insertSectionsAnimation, deleteSectionsAnimation: deleteSectionsAnimation, reloadSectionsAnimation: reloadSectionsAnimation
        )
        
        collectionChanged.invoke(eventArgs: eventArgs)
    }
}
