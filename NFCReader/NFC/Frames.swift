import SwiftUI

struct ProtocolSelectionRow: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.black)
                .padding(.leading, 16)

            Spacer()

            Image(systemName: "pencil")
                .foregroundColor(.black)
                .frame(width: 20, height: 20)
                .padding(16)
                .background(Color.box)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct ProtocolSelectorView: View {
    @State private var selectedProtocol: String = "https://"
    @State private var isShowingVariables = false

    var body: some View {
        VStack(spacing: 20) {
            Button {
                isShowingVariables = true
            } label: {
                ProtocolSelectionRow(text: selectedProtocol)
            }
            .buttonStyle(.plain)
            // 👇 Just use .navigationDestination, no new NavigationStack
            .navigationDestination(isPresented: $isShowingVariables) {
                VariablesView(selectedProtocol: $selectedProtocol)
            }
        }
    }
}

struct VariablesView: View {
    @Binding var selectedProtocol: String
    @Environment(\.dismiss) private var dismiss

    let protocols = [
        "http://",
        "https://",
        "ftp://",
        "sftp://",
        "file://",
        "rtsp://",
        "telnet://"
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .frame(width: 10, height: 20)
                            .foregroundColor(.green)
                        Text("Back")
                            .font(.custom("SF Pro Display", size: 20))
                            .foregroundColor(.green)
                    }

                }
                .padding(.leading, 20)
                Spacer()
                Text("Variables")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                    .padding(.trailing, 30)
                Spacer()
                Rectangle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.clear)
                    .padding(.trailing, 20)
            }
            .padding(.top, 65)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(protocols, id: \.self) { proto in
                        Button {
                            selectedProtocol = proto
                            dismiss()
                        } label: {
                            VariableRow(title: proto)
                        }
                        .buttonStyle(.plain)
                    }
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
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

struct VariableRow: View {
    let title: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)

                Image(systemName: "link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 10)

            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AuthenticatorSelectionRow: View {
    let text: String

    var body: some View {
        HStack {
            HStack {
                Text(text)
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                Spacer()
            }
            .frame(width: 280, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
            )
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)

                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
}

struct AuthenticatorSelectorView: View {
    @State private var selectedProtocol: String = "Open"
    @State private var isShowingVariables = false

    var body: some View {
        VStack(spacing: 20) {
            Button {
                isShowingVariables = true
            } label: {
                AuthenticatorSelectionRow(text: selectedProtocol)
            }
            .buttonStyle(.plain)
            .navigationDestination(isPresented: $isShowingVariables) {
                AuthenticatorView(selectedProtocol: $selectedProtocol)
            }
        }
    }
}

struct AuthenticatorView: View {
    @Binding var selectedProtocol: String
    @Environment(\.dismiss) private var dismiss

    let protocols = [
        "Open",
        "WPA-Personal",
        "Shared",
        "WPA-Enterprise",
        "WPA2-Enterprise",
        "WPA2-Personal",
        "WPA/WPA2-Personal"
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .frame(width: 10, height: 20)
                            .foregroundColor(.black)
                    }

                }
                .padding(.leading, 20)
                Spacer()
                Text("Authentication")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                Spacer()
                Rectangle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.clear)
                    .padding(.trailing, 20)
            }
            .padding(.top, 65)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(protocols, id: \.self) { proto in
                        Button {
                            selectedProtocol = proto
                            dismiss()
                        } label: {
                            VariableRow(title: proto)
                        }
                        .buttonStyle(.plain)
                    }
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
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

struct AuthenticatorRow: View {
    let title: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)

                Image(systemName: "highlighter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 10)

            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EncryptionSelectionRow: View {
    let text: String

    var body: some View {
        HStack {
            HStack {
                Text(text)
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                
                Spacer()
            }
            .frame(width: 280, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
            )
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)

                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal)
    }
}

struct EncryptionSelectorView: View {
    @State private var selectedProtocol: String = "None"
    @State private var isShowingVariables = false

    var body: some View {
        VStack(spacing: 20) {
            Button {
                isShowingVariables = true
            } label: {
                EncryptionSelectionRow(text: selectedProtocol)
            }
            .buttonStyle(.plain)
            .navigationDestination(isPresented: $isShowingVariables) {
                EncryptionView(selectedProtocol: $selectedProtocol)
            }
        }
    }
}

struct EncryptionView: View {
    @Binding var selectedProtocol: String
    @Environment(\.dismiss) private var dismiss

    let protocols = [
        "None",
        "WEP",
        "TKIP",
        "AES",
        "AES/TKIP"
    ]

    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .frame(width: 10, height: 20)
                            .foregroundColor(.black)
                    }

                }
                .padding(.leading, 20)
                Spacer()
                Text("Encryption")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                    .padding(.leading, 20)
                Spacer()
                Rectangle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.clear)
                    .padding(.trailing, 20)
            }
            .padding(.top, 65)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(protocols, id: \.self) { proto in
                        Button {
                            selectedProtocol = proto
                            dismiss()
                        } label: {
                            VariableRow(title: proto)
                        }
                        .buttonStyle(.plain)
                    }
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.clear)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
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

struct EncryptionRow: View {
    let title: String

    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.box)
                    .frame(width: 48, height: 48)

                Image(systemName: "lock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }

            Text(title)
                .font(.custom("SF Pro Display", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 10)

            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}
