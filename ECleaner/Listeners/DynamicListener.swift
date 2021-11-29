//
//  DynamicListener.swift
//  ECleaner
//
//  Created by alexey sorochan on 26.10.2021.
//

import Foundation

class Dynamic<T> {

    typealias Listener = (T) -> ()

    var listener: Listener?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(_ listener: Listener?) {
        self.listener = listener
    }

    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
