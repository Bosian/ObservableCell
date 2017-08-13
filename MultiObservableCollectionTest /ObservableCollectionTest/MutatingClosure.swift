//
//  Viewer.swift
//  BooKingForUser
//
//  Created by Bobson on 2016/7/21.
//  Copyright © 2016年 Bobson. All rights reserved.
//

import UIKit

/// 可在Value types 的 closure 中取得最新的ViewModel並修改回ViewController
public protocol MutatingClosure {
    weak var binder: Binder? { get }
    
    func mutating(_ closurue: (_ mutatingSelf: inout Self) -> Void) -> Void
    
    /// 立即寫回ViewController
    func commit()
}

extension MutatingClosure
{
    public func mutating(_ closurue: (_ mutatingSelf: inout Self) -> Void) -> Void
    {
        guard var viewModel = binder?.dataContext as? Self else {
            return
        }
        
        closurue(&viewModel)
        binder?.dataContext = viewModel
    }
    
    public func commit() {
        binder?.dataContext = self
    }
}
