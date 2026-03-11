import SwiftUI

struct OtherView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeAlert: AlertType? = nil
    
    @State private var storedPassword: String? = nil
    @State private var enteredPassword: String = ""
    @State private var message: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 10, height: 20)
                        .foregroundColor(.black)
                }
                .padding(.leading, 20)
                Spacer()
                Text("Other tools")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                Spacer()
                Rectangle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.clear)
                    .padding(.trailing, 20)
            }
            .padding(.top, 65)
            
            VStack(spacing: 0) {
                OtherButton(title: "Clear NFC tag", image: "trash") {
                    activeAlert = .clearTag
                }
                
                OtherButton(title: "Set password", image: "key") {
                    activeAlert = .setPassword
                }
                
                OtherButton(title: "Delete password", image: "key.slash") {
                    activeAlert = .deletePassword
                }
            }
            .padding(.horizontal)
            
            if let msg = message {
                Text(msg)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
        }
        .background(
            Image("mainBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .overlay(
            Group {
                if activeAlert != nil {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .animation(.easeInOut, value: activeAlert)
                }
            }
        )
        .overlay(alertOverlay)
        .animation(.easeInOut, value: activeAlert)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var alertOverlay: some View {
        if let type = activeAlert {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { activeAlert = nil }
                
                VStack(spacing: 16) {
                    switch type {
                    case .clearTag:
                        Text("The tag will be cleared")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("This action cannot be undone.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                    case .blockTag:
                        Text("Irreversible action!")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("The tag cannot be rewritten \nagain")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                    case .setPassword:
                        Text("Set password")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("This tag will be locked after \npassword protection. If you lose \nthe password, the tag cannot be \nchanged and this cannot be \nundone.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        ZStack(alignment: .leading) {
                            if enteredPassword.isEmpty {
                                Text("Your password")
                                    .foregroundColor(Color.black.opacity(0.5))
                                    .padding(.leading, 30)
                            }
                            SecureField("", text: $enteredPassword)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(Color.black.opacity(0.5))
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }

                    case .deletePassword:
                        Text("Delete password")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Current password")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        ZStack(alignment: .leading) {
                            if enteredPassword.isEmpty {
                                Text("Your password")
                                    .foregroundColor(Color.black.opacity(0.5))
                                    .padding(.leading, 30)
                            }
                            SecureField("", text: $enteredPassword)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(Color.black.opacity(0.5))
                                .cornerRadius(30)
                                .padding(.horizontal)
                        }
                    }
                    
                    HStack {
                        Button("Cancel") {
                            activeAlert = nil
                            enteredPassword = ""
                        }
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(100)
                        .foregroundColor(Color.black)
                        
                        Button(type.actionButtonTitle) {
                            performAction(for: type)
                        }
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                    }
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color.white)
                .cornerRadius(40)
                .shadow(radius: 10)
            }
            .transition(.opacity)
        }
        
    }
    
    private func performAction(for type: AlertType) {
        switch type {
        case .clearTag:
            NFCManager.shared.perform(.clear)
        case .blockTag:
            NFCManager.shared.perform(.block)
        case .setPassword:
            guard !enteredPassword.isEmpty else {
                message = "Your password"
                return
            }
            NFCManager.shared.perform(.setPassword(enteredPassword))
        case .deletePassword:
            guard !enteredPassword.isEmpty else {
                message = "Your password"
                return
            }
            NFCManager.shared.perform(.deletePassword(enteredPassword))
        }
        
        activeAlert = nil
        enteredPassword = ""
    }
    
    private func clearNFCTag() {
        storedPassword = nil
        message = "NFC tag cleared successfully."
        print("Cleared NFC tag")
    }
    
    private func blockNFCTag() {
        message = "NFC tag blocked (now read-only)."
        print("Blocked NFC tag")
    }
    
    private func setPassword() {
        guard !enteredPassword.isEmpty else {
            message = "Please enter a password."
            return
        }
        storedPassword = enteredPassword
        message = "Password set successfully."
        print("Password set: \(enteredPassword)")
    }
    
    private func deletePassword() {
        guard let saved = storedPassword else {
            message = "No password set."
            return
        }
        guard enteredPassword == saved else {
            message = "Incorrect password. Try again."
            return
        }
        storedPassword = nil
        message = "Password deleted successfully."
        print("Password deleted")
    }
}

enum AlertType {
    case clearTag, blockTag, setPassword, deletePassword
    
    var actionButtonTitle: String {
        switch self {
        case .clearTag: return "Clear"
        case .blockTag: return "Lock"
        case .setPassword: return "Set"
        case .deletePassword: return "Delete"
        }
    }
}

struct OtherButton: View {
    let title: String
    let image: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.box))
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
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}
