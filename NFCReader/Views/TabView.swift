import SwiftUI

enum Tab {
    case history
    case home
    case settings
}

struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let icon: String
    let text: String

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            ZStack {
                if selectedTab == tab {
                    VStack {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.green)
                        Text(text)
                            .font(.custom("SF Pro Display", size: 12))
                            .foregroundColor(.green)
                    }
                } else {
                    VStack {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                        Text(text)
                            .font(.custom("SF Pro Display", size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

