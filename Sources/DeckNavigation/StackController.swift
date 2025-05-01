import SwiftUI

@MainActor
@Observable
final class StackController {
    private(set) var stack: [AnyView] = []

    @ObservationIgnored
    var position: Binding<ScrollPosition>?

    @ObservationIgnored
    private var destinations: [ObjectIdentifier: (Any) -> any View] = [:]

    func register<Value: Hashable & Codable>(for value: Value.Type, destination: @escaping (Value) -> some View) {
        destinations[ObjectIdentifier(value)] = { value in
            guard let value = value as? Value else { return EmptyView() }
            return destination(value)
        }
    }

    func push<Value: Hashable & Codable>(_ value: Value) {
        guard let destination = destinations[ObjectIdentifier(Value.self)] else { return }
        stack.append(AnyView(destination(value)))
        withAnimation(.interactiveSpring) {
            position?.wrappedValue = .init(id: stack.count - 1)
        }
    }

    func pop() {
        _ = stack.popLast()
    }
}
