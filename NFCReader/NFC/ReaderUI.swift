import SwiftUI
import CoreNFC

struct ReadView: View {
    @StateObject private var nfcVM = NFCReaderViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if nfcVM.isScanning {
                    Image("splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .offset(y: -100)
                    Spacer()
                    Image("reader")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 321, height: 266)
                        .padding(.bottom, 210)
                    Spacer()
                } else if let tag = nfcVM.tagInfo {
                    Spacer()
                    Image("successful")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 321, height: 266)
                    Spacer()
                    NavigationLink(destination: NFCResultView(tag: tag) {
                        nfcVM.beginScanning()
                    }) {
                        Text("Show Results")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color.scanButton.opacity(0.5))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 60)
                } else if let error = nfcVM.scanError {
                    VStack {
                        Spacer()
                        Image("failed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 321, height: 266)
                        Spacer()
                        Button(action: {
                            nfcVM.beginScanning()
                        }) {
                            Text("Try Again")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Color.scanButton.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 60)
                    }
                } else {
                    VStack {
                        Image("splash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .offset(y: -100)
                        Spacer()
                        Image("reader")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 321, height: 266)
                            .padding(.bottom, 100)
                        Spacer()
                        Button(action: {
                            nfcVM.beginScanning()
                        }) {
                            Text("Start NFC Scan")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Color.scanButton.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 60)
                    }
                }
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
            .onAppear {
                if nfcVM.tagInfo != nil || nfcVM.scanError != nil {
                    nfcVM.reset()
                }
            }
        }
    }
}

struct NFCResultView: View {
    let tag: TagInfo
    let onRescan: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isSaved = false
    
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
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    NFCSavedTagManager().saveTag(tag)
                    isSaved = true
                }) {
                    Text(isSaved ? "Saved" : "Save")
                        .font(.custom("SF Pro Display", size: 20)).bold()
                        .foregroundColor(isSaved ? .gray : .saveButton)
                }
                .disabled(isSaved)
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
                        NFCResultRow(title: "Protected by password", value: "No", image: "key.icloud")
                        NFCResultRow(title: "Memory information", value: tag.memorySize, image: "square.grid.3x3")
                        NFCResultRow(title: "Data format", value: tag.dataFormat, image: "chart.bar.doc.horizontal")
                        NFCResultRow(title: "Size", value: tag.memorySize, image: "rectangle.badge.checkmark")
                        NFCResultRow(title: "Writable", value: tag.writable ? "Yes" : "No", image: "arrow.clockwise")
                        NFCResultRow(title: "Records", value: tag.records.joined(separator: ", "), image: "link", isFlexibleHeight: true)
                        
                        Rectangle()
                            .frame(height: 30)
                            .foregroundStyle(Color.clear)
                    }                    .background(Color.white.opacity(0.15))
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
        .onAppear {
            isSaved = NFCSavedTagManager()
                .loadSavedTags()
                .contains(where: { $0.hardware?.serialNumber == tag.hardware?.serialNumber })
        }
    }
}

struct NFCResultRow: View {
    let title: String
    let value: String
    var image: String
    var isFlexibleHeight: Bool = false

    var body: some View {
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
            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom("SF Pro Display", size: 16)).bold()
                    .foregroundColor(.black)
                    .padding(.bottom, 1)
                Text(value)
                    .font(.custom("SF Pro Display", size: 14))
                    .foregroundColor(.black)
                    .padding(.top, 1)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 10)
            Spacer()
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



