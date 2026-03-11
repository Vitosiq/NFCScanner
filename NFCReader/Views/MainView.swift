import SwiftUI
// MARK: - main screen
struct MainView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .history:
                        HistoryView()
                    case .settings:
                        SettingsView()
                    }
                    
                }
                
                Spacer(minLength: 0)
                if selectedTab == .home {
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
                            .frame(maxHeight: .infinity, alignment: .top), // ✅ top border only
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

struct HomeView: View {

    @State private var selectedDestination: AnyView? = nil
    @State private var navigate = false
    @State private var isNavigating = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack (alignment: .leading){
                        Text("Welcome!")
                            .font(.custom("SF Pro Display", size: 24)).bold()
                            .foregroundColor(.black)
            
                        Text("to NFC Platform")
                            .font(.custom("SF Pro Display", size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                VStack(spacing: 0) {
                    
                    MainButton(
                        title: "Read",
                        image: "books.vertical"
                    ) {
                        navigateTo(destination: AnyView(ReadView()))
                    }
                    
                    MainButton(
                        title: "Write",
                        image: "pencil"
                    ) {
                        navigateTo(destination: AnyView(WriteView()))
                    }
                    
                    MainButton(
                        title: "Other",
                        image: "folder"
                    ) {
                        navigateTo(destination: AnyView(OtherView()))
                    }

                    MainButton(
                        title: "Saved Tags",
                        image: "bookmark"
                    ) {
                        navigateTo(destination: AnyView(SavedTagsView()))
                    }
                    
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 178, height: 178)
                        .padding(.top, 20)

                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(
                Image("mainBackground")
                    .resizable()
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: selectedDestination,
                    isActive: $navigate,
                    label: { EmptyView() }
                )
                .onChange(of: navigate) { newValue in
                    if !newValue { isNavigating = false }
                }
            )
        }
    }

    private func navigateTo(destination: AnyView) {
        guard !isNavigating else { return }
        selectedDestination = destination
        navigate = true
        isNavigating = true
    }
}

struct MainButton: View {
    let title: String
    let image: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.box)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                Text(title)
                    .font(.custom("SF Pro Display", size: 14))
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


