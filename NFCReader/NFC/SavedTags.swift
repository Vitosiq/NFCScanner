import SwiftUI

struct SavedTagsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var savedTags: [TagInfo] = []
    @State private var selectedTag: TagInfo? = nil
    @State private var isNavigating: Bool = false
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
                Text("Saved Tags")
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
                    if savedTags.isEmpty {
                        // Empty state message
                        VStack {
                            Text("History is empty")
                                .font(.custom("SF Pro Display", size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                    } else {
                        ForEach(savedTags) { tag in
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
                savedTags = NFCSavedTagManager().loadSavedTags()
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("mainBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .background(
            NavigationLink(
                destination: Group {
                    if let tag = selectedTag {
                        NFCResultHistoryView(tag: tag, onRescan: { isNavigating = false })
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

class NFCSavedTagManager {
    private let savedKey = "savedNFCTags"

    func saveTag(_ tag: TagInfo) {
        var saved = loadSavedTags()
        if !saved.contains(where: { $0.hardware?.serialNumber == tag.hardware?.serialNumber }) {
            saved.insert(tag, at: 0)
        }
        if saved.count > 50 {
            saved.removeLast()
        }
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: savedKey)
        }
    }

    func loadSavedTags() -> [TagInfo] {
        guard let data = UserDefaults.standard.data(forKey: savedKey),
              let tags = try? JSONDecoder().decode([TagInfo].self, from: data) else {
            return []
        }
        return tags
    }

    func deleteTag(_ tag: TagInfo) {
        var saved = loadSavedTags()
        saved.removeAll { $0.hardware?.serialNumber == tag.hardware?.serialNumber }
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: savedKey)
        }
    }
}

