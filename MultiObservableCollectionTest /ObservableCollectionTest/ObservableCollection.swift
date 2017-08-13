//
//  ObservableCollection.swift
//  MVVMTest
//
//  Created by 劉柏賢 on 2015/12/27.
//  Copyright © 2015年 劉柏賢. All rights reserved.
//

import UIKit

public class ObservableCollection<TRow>: CollectionChangedProtocol, Collection {
    
    public typealias Element = TRow
    
    public var collectionChanged = CollectionChange()
    
    public private(set) var collection: [TRow] = []
    
    var section: Int
    
    private let insertRowsAnimation: UITableViewRowAnimation
    private let deleteRowsAnimation: UITableViewRowAnimation
    private let reloadRowsAnimation: UITableViewRowAnimation
    
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
    
    public subscript(index: Int) -> TRow
    {
        get {
            return collection[index]
        }
        
        set {
            collection[index] = newValue
            
            notifyCollectionChanged(reloadRows: [IndexPath(row: index, section: section)])
        }
    }
    
    public init(section: Int = 0, insertRowsAnimation: UITableViewRowAnimation = .none, deleteRowsAnimation: UITableViewRowAnimation = .none, reloadRowsAnimation: UITableViewRowAnimation = .none) {
        self.section = section
        
        self.insertRowsAnimation = insertRowsAnimation
        self.deleteRowsAnimation = deleteRowsAnimation
        self.reloadRowsAnimation = reloadRowsAnimation
    }
    
    public init(_ collection: [TRow], section: Int, insertRowsAnimation: UITableViewRowAnimation = .none, deleteRowsAnimation: UITableViewRowAnimation = .none, reloadRowsAnimation: UITableViewRowAnimation = .none)
    {
        self.section = section
        self.collection = collection
        
        self.insertRowsAnimation = insertRowsAnimation
        self.deleteRowsAnimation = deleteRowsAnimation
        self.reloadRowsAnimation = reloadRowsAnimation
    }
    
    public func append(_ item: TRow)
    {
        let index = collection.count
        print("\(#function): \(index)")
        collection.append(item)
        
        notifyCollectionChanged(insertRows: [IndexPath(row: index, section: section)])
    }
    
    public func append(contentOf items: [TRow])
    {
        let startIndex = collection.count
        
        var insertRows: [IndexPath] = []
        
        for index in 0..<items.count
        {
            let item = items[index]
            let collectionIndex = startIndex + index
            
            print("\(#function): \(collectionIndex)")
            collection.append(item)
            
            insertRows.append(IndexPath(row: collectionIndex, section: section))
        }
        
        notifyCollectionChanged(insertRows: insertRows)
    }
    
    
    public func insert(_ item: TRow, at index: Int)
    {
        print("\(#function): \(index)")
        collection.insert(item, at: index)
        
        notifyCollectionChanged(insertRows: [IndexPath(row: index, section: section)])
    }
    
    public func remove(at index: Int)
    {
        print("\(#function): \(index)")
        print(collection)
        collection.remove(at: index)
        
        notifyCollectionChanged(deleteRows: [IndexPath(row: index, section: section)])
    }
    
    public func removeAll()
    {
        print("\(#function): count = \(collection.count)")
        
        var deleteRows: [IndexPath] = []
        for index in (0..<collection.count).reversed() {
            deleteRows.append(IndexPath(row: index, section: section))
        }
        
        collection.removeAll()
        
        notifyCollectionChanged(deleteRows: deleteRows)
    }
    
    public func notifyCollectionChanged(insertRows: [IndexPath] = [], reloadRows: [IndexPath] = [], deleteRows: [IndexPath] = [])
    {
        let eventArgs = CollectionEventArgs(insertRows: insertRows, deleteRows: deleteRows, reloadRows: reloadRows,
                                            insertSections: nil, deleteSections: nil, reloadSections: nil,
                                            insertRowsAnimation: insertRowsAnimation, deleteRowsAnimation: deleteRowsAnimation, reloadRowsAnimation: reloadRowsAnimation,
                                            insertSectionsAnimation: .none, deleteSectionsAnimation: .none, reloadSectionsAnimation: .none
        )
        
        collectionChanged.invoke(eventArgs: eventArgs)
    }
}
