//
//  View+withoutAnimation.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 21.10.2025.
//

import SwiftUI

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
