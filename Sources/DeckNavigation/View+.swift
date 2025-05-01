public import SwiftUI

public extension View {
    func deckNavigationDestination<Value: Hashable & Codable>(
        for value: Value.Type,
        @ViewBuilder destination: @escaping (Value) -> some View
    ) -> some View {
        modifier(NavigationDestinationModifier(value: value, destination: destination))
    }
}

private struct NavigationDestinationModifier<Value: Hashable & Codable, Destination: View>: ViewModifier {
    var value: Value.Type
    var destination: (Value) -> Destination

    @Environment(StackController.self) private var controller

    func body(content: Content) -> some View {
        content
            .task(id: ObjectIdentifier(value)) {
                controller.register(for: value, destination: destination)
            }
    }
}
