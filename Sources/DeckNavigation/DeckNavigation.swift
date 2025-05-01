public import SwiftUI

public struct DeckNavigationStack<NavigationBar: View, Content: View>: View {
    @ViewBuilder var navigationBar: () -> NavigationBar
    @ViewBuilder var content: () -> Content

    @State private var controller = StackController()
    @State private var position = ScrollPosition(id: -1)

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder navigationBar: @escaping () -> NavigationBar = { Color.clear.frame(height: 0) }
    ) {
        self.content = content
        self.navigationBar = navigationBar
    }

    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                card {
                    content()
                }
                .id(-1)

                ForEach(0..<controller.stack.count, id: \.self) { i in
                    card {
                        controller.stack[i]
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.never)
        .scrollTargetBehavior(.paging)
        .scrollPosition($position)
        .onScrollTargetVisibilityChange(idType: Int.self, threshold: 1) { ids in
            guard let id = ids.first else { return }
            if id != controller.stack.count - 1 {
                controller.pop()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navigationBar()
                .environment(\.pop, PopAction {
                    withAnimation(.interactiveSpring.speed(0.3)) {
                        controller.pop()
                    }
                })
                .environment(\.canPop, !controller.stack.isEmpty)
        }
        .environment(controller)
        .onAppear {
            controller.position = $position
        }
    }

    @ViewBuilder
    private func card(@ViewBuilder _ content: () -> some View) -> some View {
        content()
            .containerRelativeFrame(.horizontal)
            .visualEffect { effect, proxy in
                let frame = proxy.frame(in: .scrollView(axis: .horizontal))
                let distance = min(0, frame.minX)

                return effect
                    .scaleEffect(1.0 + distance / 3600)
                    .offset(x: -min(0, distance))
                    .blur(radius: -distance / 150)
            }
            .scrollTransition(axis: .horizontal) { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0)
            }
    }
}

#Preview {
    struct NavigationBar: View {
        @Environment(\.pop) var pop
        @Environment(\.canPop) var canPop

        var body: some View {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                ))
                .frame(height: 48)
                .overlay(alignment: .leading) {
                    Button {
                        pop()
                    } label: {
                        Circle()
                            .fill(.thinMaterial)
                            .overlay(Circle().stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.2)]),
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.4
                            ))
                            .overlay {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .padding(8)
                    .disabled(!canPop)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }

    struct CardView: View {
        var title: String
        var value: Int

        var body: some View {
            ZStack {
                Color.clear

                VStack {
                    Text(title)

                    DeckNavigationLink(value: value) {
                        Text("press")
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)]),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    ))
            )
            .padding(.horizontal)
            .preferredColorScheme(.dark)
        }
    }

    return ZStack {
        Rectangle()
            .fill(Color.blue.gradient)
            .ignoresSafeArea()

        DeckNavigationStack {
            CardView(title: "root", value: 1)
                .deckNavigationDestination(for: Int.self) { i in
                    CardView(title: "\(i)", value: i + 1)
                        .onAppear {
                            print("\(i) appeared")
                        }
                        .onDisappear {
                            print("\(i) disappeared")
                        }
                }
        } navigationBar: {
            NavigationBar()
        }
    }
}
