import SwiftUI

struct HistoryView: View {
    @State private var selectedTab: Tab = .history
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab {
                    case .home:
                        MainView()
                    case .history:
                        HistoryViewUI(selectedTab: $selectedTab)
                    case .settings:
                        SettingsView()
                    }
                    
                }
                
                Spacer(minLength: 0)
                if selectedTab == .history {
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

struct HistoryViewUI: View {
    @Environment(\.dismiss) private var dismiss
    @State private var history: [TagInfo] = []
    @Binding var selectedTab: Tab
    @State private var selectedTag: TagInfo? = nil
    @State private var isNavigating: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("History")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
            }
            .padding(.top, 65)
            
            ScrollView {
                VStack(spacing: 0) {
                    if history.isEmpty {
                        VStack {
                            Text("History is empty")
                                .font(.custom("SF Pro Display", size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    } else {
                        ForEach(history) { tag in
                            Button {
                                guard !isNavigating else { return }
                                selectedTag = tag
                                isNavigating = true
                            } label: {
                                NFCHistoryRow(
                                    title: tag.tagType,
                                    value: tag.hardware?.serialNumber ?? "-"
                                )
                            }
                        }
                        Rectangle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.clear)
                    }

                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .onAppear {
                history = NFCHistoryManager().loadHistory()
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            NavigationLink(
                destination: Group {
                    if let tag = selectedTag {
                        NFCResultHistoryView(tag: tag, onRescan: {
                            isNavigating = false
                        })
                    } else {
                        EmptyView()
                    }
                },
                isActive: Binding(
                    get: { selectedTag != nil },
                    set: { active in
                        if !active {
                            selectedTag = nil
                            isNavigating = false
                        }
                    }
                ),
                label: { EmptyView() }
            )
        )
    }
}

struct NFCResultHistoryView: View {
    let tag: TagInfo
    let onRescan: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 10, height: 20)
                        .foregroundColor(.black)
                }
                .padding(.leading, 20)
                Spacer()
                Text("Tag Info")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                Spacer()
                Rectangle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.clear)
                    .padding(.trailing, 20)
 
            }
            .padding(.top, 65)
            
            ScrollView {
                VStack(spacing: 0) {

                    VStack(alignment: .leading, spacing: 0) {
                        NFCResultRow(title: "Tag Type", value: tag.tagType, image: "n.circle")
                        NFCResultRow(title: "Technologies available", value: tag.technologies.joined(separator: ", "), image: "info.circle")
                        NFCResultRow(title: "Serial number", value: tag.hardware?.serialNumber ?? "-", image: "key")
                        NFCResultRow(title: "ATQA", value: tag.hardware?.atqa ?? "-", image: "arrow.forward")
                        NFCResultRow(title: "SAK", value: tag.hardware?.sak ?? "-", image: "bubble")
                        NFCResultRow(title: "Memory information", value: tag.memorySize, image: "square.grid.3x3")
                        NFCResultRow(title: "Data format", value: tag.dataFormat, image: "chart.bar.doc.horizontal")
                        NFCResultRow(title: "Writable", value: tag.writable ? "Yes" : "No", image: "arrow.clockwise")
                        NFCResultRow(title: "Records", value: tag.records.joined(separator: ", "), image: "link", isFlexibleHeight: true)
                        
                        Rectangle()
                            .frame(height: 30)
                            .foregroundStyle(Color.clear)
                    }
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .background(
            Image("mainBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct NFCHistoryRow: View {
    let title: String
    let value: String
    var isFlexibleHeight: Bool = false
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "n.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom("SF Pro Display", size: 16)).bold()
                    .foregroundColor(.black)
                    .padding(.bottom, 1)
                Text(value)
                    .font(.custom("SF Pro Display", size: 14))
                    .foregroundColor(.black)
                    .padding(.top, 1)
            }
            .padding(.leading, 10)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .frame(width: 14, height: 14)
        }
        .padding(.horizontal)
        .frame(minHeight: isFlexibleHeight ? 80 : 80, maxHeight: isFlexibleHeight ? .infinity : 80)
        .background(Color.insideFrame)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.frame, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

class NFCHistoryManager {
    private let historyKey = "nfcHistoryTags"

    func saveTag(_ tag: TagInfo) {
        var history = loadHistory()
        history.insert(tag, at: 0)
        if history.count > 50 {
            history.removeLast()
        }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    func loadHistory() -> [TagInfo] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let tags = try? JSONDecoder().decode([TagInfo].self, from: data) else {
            return []
        }
        return tags
    }
}


