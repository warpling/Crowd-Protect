//
//  Configurable.swift
//  byte
//
//  Created by Pim Coumans on 24/04/2020.
//  Copyright © 2020 V2. All rights reserved.
//

import UIKit

/// Adds a `configure` method with a closure that is executed with `Self` as a parameter
protocol Configurable { }

extension Configurable {
    /// Configures the instance with a closure that is executed with `Self` as a parameter
    /// - Parameter configurer: Closure exectured immediately with `Self` as a parameter
    /// - Parameter instance: Use this parameter to 'configure' the instance
    func configure(with configurer: (_ instance: Self) -> ()) {
        configurer(self)
    }
}

/// Allows the type to be initialized with a configuration closure, requiring it to at least have an `init()` method
protocol InitConfigurable: Configurable {
    init()
}

extension InitConfigurable {
    
    /// Initailizes the type with a closure that is executed with `Self` as a parameter
    /// - Parameter configurer: Closure called immidiately after initialization. Use it to configure the instance
    /// - Parameter instance: Use this parameter to 'configure' the instance
    init(with configurer: (_ instance: Self) -> ()) {
        self.init()
        configure(with: configurer)
    }
}

extension NSObject: InitConfigurable { }
