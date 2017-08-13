//
//  CollectionChangedProtocol.swift
//  MVVMTest
//
//  Created by 劉柏賢 on 2015/12/27.
//  Copyright © 2015年 劉柏賢. All rights reserved.
//

import UIKit

public protocol CollectionChangedProtocol {
    
    /// 註冊Collection變更
    var collectionChanged: CollectionChange { get set }
    
    /// 通知 Collection 變更
    func notifyCollectionChanged(insertRows: [IndexPath], reloadRows: [IndexPath], deleteRows: [IndexPath])
}
