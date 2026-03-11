import SwiftUI
import StoreKit
import UIKit
// MARK: - settings
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsView: View {
    @State private var selectedTab: Tab = .settings
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        MainView()
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsViewUI(selectedTab: $selectedTab)
                    }
                    
                }
                
                Spacer(minLength: 0)
                if selectedTab == .settings {
                    ZStack {
                        Color.white
                        
                        HStack {
                            Spacer()
                            TabButton(tab: .home, selectedTab: $selectedTab, icon: "house", text: "Home").padding(.leading, 10)
                            Spacer()
                            TabButton(tab: .history, selectedTab: $selectedTab, icon: "clock", text: "History")
                            Spacer()
                            TabButton(tab: .settings, selectedTab: $selectedTab, icon: "gear", text: "Settings").padding(.trailing, 10)
                            Spacer()
                        }
                        .padding(.bottom, 40)
                        .frame(height: 100)
                    }
                    .frame(height: 100)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(maxHeight: .infinity, alignment: .top),
                        alignment: .top
                    )
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .background(
                Image("mainBackground")
                    .resizable()
                    .ignoresSafeArea()
            )
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct SettingsViewUI: View {
    let privacy = URL(string: "https://www.google.com/")!
    let terms = URL(string: "https://www.google.com/")!
    let share = URL(string: "https://www.google.com/")!
    @State private var showShareSheet = false
    @State private var isButtonLocked = false
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.custom("SF Pro Display", size: 24)).bold()
                    .foregroundColor(.black)
            }
            .padding(.top, 65)
            
            VStack(spacing: 0) {
                SettingsButton(
                    title: "Rate Us",
                    image: "hand.thumbsup.fill",
                    url: nil,
                    action: {
                        guard !isButtonLocked else { return }
                        isButtonLocked = true
                        if let scene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                        unlockAfterDelay()
                    },
                    disabled: isButtonLocked
                )
                
                SettingsButton(
                    title: "Share",
                    image: "paperplane.circle",
                    url: nil,
                    action: {
                        guard !isButtonLocked else { return }
                        isButtonLocked = true
                        showShareSheet = true
                        unlockAfterDelay()
                    },
                    disabled: isButtonLocked
                )
                
                SettingsButton(
                    title: "Terms of Use",
                    image: "list.clipboard",
                    url: terms,
                    action: {
                        guard !isButtonLocked else { return }
                        isButtonLocked = true
                        UIApplication.shared.open(terms)
                        unlockAfterDelay()
                    },
                    disabled: isButtonLocked
                )
                
                SettingsButton(
                    title: "Privacy Policy",
                    image: "shield",
                    url: privacy,
                    action: {
                        guard !isButtonLocked else { return }
                        isButtonLocked = true
                        UIApplication.shared.open(privacy)
                        unlockAfterDelay()
                    },
                    disabled: isButtonLocked
                )
            }
            .padding(.horizontal)
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: ["Share us", share])
            }
            
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func unlockAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isButtonLocked = false
        }
    }
}
    
struct SettingsButton: View {
    var title: String
    var image: String
    var url: URL?
    var action: (() -> Void)? = nil
    var disabled: Bool = false

    var body: some View {
        Button(action: {
            guard !disabled else { return }
            if let action = action {
                action()
            } else if let url = url {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.box)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.black)
                }
                Text(title)
                    .font(.custom("SF Pro Display", size: 20))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .frame(width: 14, height: 14)
            }
            .padding(.horizontal)
            .frame(height: 80)
            .background(Color.insideFrame)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.frame, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

