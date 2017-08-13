//
//  CollectionChange.swift
//  BrandApp
//
//  Created by Bobson on 2016/1/12.
//  Copyright © 2016年 Bobson. All rights reserved.
//

import UIKit

public typealias CollectionChangeListener = (_ eventArgs: CollectionEventArgs) -> Void

/// 給View註冊屬性變更
public class CollectionChange
{
    public private(set) var propertyChanged = [CollectionChangeListener]()
    
    public func append(_ parameter: CollectionChangeParameter)
    {
        let receiver = parameter.receiver
        
        propertyChanged.append(receiver)
    }
    
    /// 通知所有註冊的View
    ///
    /// - Parameter eventArgs: eventArgs description
    public func invoke(eventArgs: CollectionEventArgs)
    {
        for method in propertyChanged
        {
            method(eventArgs)
        }
    }
    
    public func removeAll()
    {
        propertyChanged.removeAll()
    }
}

public struct CollectionEventArgs {
    public let insertRows: [IndexPath]
    public let deleteRows: [IndexPath]
    public let reloadRows: [IndexPath]
    
    public let insertSections: IndexSet?
    public let deleteSections: IndexSet?
    public let reloadSections: IndexSet?
    
    public let insertRowsAnimation: UITableViewRowAnimation
    public let deleteRowsAnimation: UITableViewRowAnimation
    public let reloadRowsAnimation: UITableViewRowAnimation
    
    public let insertSectionsAnimation: UITableViewRowAnimation
    public let deleteSectionsAnimation: UITableViewRowAnimation
    public let reloadSectionsAnimation: UITableViewRowAnimation
}

public struct CollectionChangeParameter
{
    public var receiver: CollectionChangeListener
    
    public init(method receiver: @escaping CollectionChangeListener) {
        self.receiver = receiver
    }
}

public func += (left: inout CollectionChange, right: CollectionChangeParameter)
{
    left.append(right)
}
