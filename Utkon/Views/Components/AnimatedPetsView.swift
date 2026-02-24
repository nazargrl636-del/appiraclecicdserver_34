import SwiftUI
import Combine

struct SittingDogView: View {
    @State private var tailWag: Double = 0
    @State private var tongueLength: CGFloat = 10

    let wagTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    let tongueTimer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.76, green: 0.6, blue: 0.42), Color(red: 0.65, green: 0.5, blue: 0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 38)

            Circle()
                .fill(Color(red: 0.76, green: 0.6, blue: 0.42))
                .frame(width: 28, height: 28)
                .offset(y: -26)

            Capsule()
                .fill(Color(red: 0.65, green: 0.5, blue: 0.35))
                .frame(width: 10, height: 16)
                .rotationEffect(.degrees(-15))
                .offset(x: -10, y: -36)

            Capsule()
                .fill(Color(red: 0.65, green: 0.5, blue: 0.35))
                .frame(width: 10, height: 16)
                .rotationEffect(.degrees(15))
                .offset(x: 10, y: -36)

            Circle()
                .fill(.black)
                .frame(width: 4, height: 4)
                .offset(x: -5, y: -28)

            Circle()
                .fill(.black)
                .frame(width: 4, height: 4)
                .offset(x: 5, y: -28)

            Circle()
                .fill(.black)
                .frame(width: 5, height: 5)
                .offset(y: -23)

            Capsule()
                .fill(Color(red: 1.0, green: 0.4, blue: 0.5))
                .frame(width: 6, height: tongueLength)
                .offset(y: -16 + (tongueLength - 10) / 2)

            Ellipse()
                .fill(Color(red: 0.65, green: 0.5, blue: 0.35))
                .frame(width: 10, height: 14)
                .offset(x: -10, y: 12)

            Ellipse()
                .fill(Color(red: 0.65, green: 0.5, blue: 0.35))
                .frame(width: 10, height: 14)
                .offset(x: 10, y: 12)

            Capsule()
                .fill(Color(red: 0.65, green: 0.5, blue: 0.35))
                .frame(width: 8, height: 14)
                .rotationEffect(.degrees(tailWag), anchor: .bottom)
                .offset(x: 18, y: -5)
        }
        .onReceive(wagTimer) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                tailWag = tailWag > 0 ? -20 : 20
            }
        }
        .onReceive(tongueTimer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                tongueLength = tongueLength == 10 ? 14 : 10
            }
        }
    }
}

struct PetAnimationsOverlay: View {
    var body: some View {
        EmptyView()
    }
}

struct AnimatedEmptyStateView: View {
    var body: some View {
        EmptyView()
    }
}

#Preview {
    SittingDogView()
}
