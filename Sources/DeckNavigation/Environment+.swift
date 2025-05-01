public import SwiftUI

extension EnvironmentValues {
    @Entry public var pop = PopAction(action: {})

    @Entry public var canPop = false
}

public struct PopAction {
    var action: () -> Void

    public func callAsFunction() {
        action()
    }
}
