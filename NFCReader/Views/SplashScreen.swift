import SwiftUI
import AppTrackingTransparency
import UserNotifications

struct SplashScreen: View {
    
    @State private var didAnimate = false
    @State private var imagePosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("mainBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                if didAnimate {
                    MainView()
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                                Task {
                                    let result = await ATTrackingManager.requestTrackingAuthorization()
                                    switch result {
                                    case .notDetermined:
                                        break
                                    case .restricted, .denied, .authorized:
                                        timer.invalidate()
                                    @unknown default:
                                        break
                                    }
                                }
                            }
                        }
                        .task {
                            let center = UNUserNotificationCenter.current()
                            do {
                                try await center.requestAuthorization(options: [.alert, .sound, .badge])
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                } else {
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 178, height: 178)
                        .position(imagePosition == .zero
                                  ? CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                                  : imagePosition)
                        .onAppear {
                            startAnimation(in: geo.size)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("mainBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .ignoresSafeArea()
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(4.0))
                withAnimation {
                    didAnimate = true
                }
            }
        }
    }
    
    private func startAnimation(in size: CGSize) {
        imagePosition = CGPoint(x: size.width * 0.2, y: size.height * 0.2)
        
        withAnimation(.easeInOut(duration: 2)) {
            imagePosition = CGPoint(x: size.width * 0.8, y: size.height * 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 1.5)) {
                imagePosition = CGPoint(x: size.width * 0.3, y: size.height * 0.85)
            }
        }
    }
}
