public import SwiftUI

public struct DeckNavigationLink<Label: View>: View {
    public init<Data: Hashable & Codable>(
        value: Data?,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.disabled = value == nil
        self.label = label
        self.action = { controller in
            guard let value else { return }
            controller.push(value)
        }
    }

    @Environment(StackController.self) private var controller

    @ViewBuilder private var label: () -> Label
    private var disabled: Bool
    private var action: (StackController) -> Void

    public var body: some View {
        Button {
            action(controller)
        } label: {
            label()
        }
        .disabled(disabled)
    }
}
