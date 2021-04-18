//
//  StatableNode.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import Foundation

enum State {
    case inactive
    case active
    
    mutating func transition() {
        switch self {
        case .active:
            self = .inactive
        case .inactive:
            self = .active
        }
    }
    
    mutating func active() {
        self = .active
    }
    
    mutating func inactive() {
        self = .inactive
    }
}

protocol StatableNode {
    var state: State { get set }
}
