import SwiftUI
import CoreNFC

struct WriteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDestination: AnyView? = nil
    @State private var navigate = false
    @State private var isNavigating = false
    
    var body: some View {
        NavigationStack {
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
                    Text("Writing")
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
                        
                        WriterButton(
                            title: "Text",
                            subtitle: "Add a text record",
                            image: "text.document"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Text", image: "text.document", insideImage: "ellipsis.curlybraces", subtitle: "Enter your text")))
                        }
                        
                        WriterButton(
                            title: "URL",
                            subtitle: "Add URL",
                            image: "curlybraces"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "URL", image: "curlybraces", insideImage: "ellipsis.curlybraces", subtitle: "Enter your URL")))
                        }
                        
                        WriterButton(
                            title: "Phone Number",
                            subtitle: "Add phone number",
                            image: "phone"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Phone Number", image: "phone", insideImage: "person", subtitle: "Enter your phone number")))
                        }
                        
                        WriterButton(
                            title: "Contact",
                            subtitle: "Add a contact",
                            image: "person"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Contact", image: "person", insideImage: nil, subtitle: "Enter your contact")))
                        }
                        
                        WriterButton(
                            title: "SMS",
                            subtitle: "Add SMS",
                            image: "ellipsis.message"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "SMS", image: "ellipsis.message", insideImage: "person", subtitle: "Enter your SMS")))
                        }
                        
                        WriterButton(
                            title: "Email",
                            subtitle: "Add Email",
                            image: "mail"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Email",  image: "mail", insideImage: "person", subtitle: "Enter your mail content")))
                        }
                        
                        WriterButton(
                            title: "FaceTime",
                            subtitle: "Add FaceTime",
                            image: "camera"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "FaceTime", image: "camera", insideImage: "person", subtitle: "Enter your phone number or email")))
                        }
                        
                        WriterButton(
                            title: "Wi-Fi network",
                            subtitle: "Set up a Wi-Fi network",
                            image: "wifi"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Wi-Fi network", image: "wifi", insideImage: "pencil", subtitle: "Configure a Wi-Fi network")))
                        }
                        
                        WriterButton(
                            title: "Bluetooth",
                            subtitle: "Add Bluetooth connection",
                            image: "phone.connection"
                        ) {
                            navigateTo(destination: AnyView(AddRecordView(title: "Bluetooth", image: "phone.connection", insideImage: nil, subtitle: "Configure a Bluetooth connection")))
                        }
                        Rectangle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
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
    
    private func navigateTo(destination: AnyView) {
        guard !isNavigating else { return }
        selectedDestination = destination
        navigate = true
        isNavigating = true
    }
}

struct WriterButton: View {
    let title: String
    let subtitle: String
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
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom("SF Pro Display", size: 16)).bold()
                        .foregroundColor(.black)
                        .padding(.bottom, 1)
                    Text(subtitle)
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

struct AddRecordView: View {
    let title: String
    let image: String
    let insideImage: String?
    let subtitle: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var textField1: String = ""
    @State private var textField2: String = ""
    @State private var textField3: String = ""
    @State private var textField4: String = ""
    @State private var textField5: String = ""
    @State private var textField6: String = ""
    @State private var isWriting: Bool = false
    @State private var writeStatus: String = ""
    
    @State private var nfcWriter: NFCWriter? = nil
    
    var body: some View {
        VStack {
            
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
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 120)
            
            HStack {
                Text(subtitle)
                    .font(.custom("SF Pro Display", size: 18))
                    .foregroundColor(.black)
                Spacer()
                if title == "Text" {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: insideImage ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            if title == "URL" {
                ProtocolSelectorView()
                    .padding(.top, 20)
            }
            
            if title == "Wi-Fi network" {
                VStack {
                    HStack {
                        Text("Authenticator :")
                            .font(.custom("SF Pro Display", size: 18))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        Spacer()
                    }
                    .padding(.horizontal)
                    AuthenticatorSelectorView()
                        .padding(.top, 10)
                    HStack {
                        Text("Encryption :")
                            .font(.custom("SF Pro Display", size: 18))
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        Spacer()
                    }
                    .padding(.horizontal)
                    EncryptionSelectorView()
                        .padding(.top, 10)
                }
            }
            
            formFields
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .frame(width: 10, height: 20)
                        .foregroundColor(.black)
                        .background(Color.clear)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .principal) {
                Text("Add a record")
                    .font(.custom("SF Pro Display", size: 20)).bold()
                    .foregroundColor(.black)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: writeToTag) {
                    Text("Save")
                        .font(.custom("SF Pro Display", size: 20)).bold()
                        .foregroundColor(.saveButton)
                        .background(Color.clear)
                }
                .buttonStyle(.plain)
                .disabled(isWriting)
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea()
        .background(
            Image("mainBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
        )
    }
    
    @ViewBuilder
    private var formFields: some View {
        VStack(spacing: 16) {
            switch title {
            case "Text":
                textTextInput(label: "Hello!", binding: $textField1)
                
            case "URL":
                HStack {
                    textInput(label: "www.crowndev.com", binding: $textField1)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "ellipsis.curlybraces")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                
            case "Phone Number":

                HStack {
                    textInput(label: "3141592654", binding: $textField1)
                        .keyboardType(.phonePad)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                
            case "Contact":
                HStack {
                    Text("Contact name :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "Juliet", binding: $textField1)
                }
                HStack {
                    Text("Company :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "crowndev", binding: $textField2)
                }
                HStack {
                    Text("Address :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "Maplewood Drive, Portland, USA", binding: $textField3)
                }
                HStack {
                    Text("Phone :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "3141592654", binding: $textField4)
                }
                HStack {
                    Text("Mail :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "j.k.2147@crowndev.com", binding: $textField5)
                }
                HStack {
                    Text("Website :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "https://crowndev.com", binding: $textField6)
                }
                
            case "SMS":
                HStack {
                    Text("To :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "3141592654", binding: $textField1)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }

                VStack {
                    HStack {
                        Text("Message :")
                            .font(.custom("SF Pro Display", size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
                textTextInput(label: "Message", binding: $textField2)
                
            case "Email":
                HStack {
                    Text("To :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "j.k.2147@crowndev.com", binding: $textField1)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
                HStack {
                    Text("Object :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "This app is good!!!", binding: $textField2)
                }
                VStack {
                    HStack {
                        Text("Message :")
                            .font(.custom("SF Pro Display", size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
                textTextInput(label: "Message", binding: $textField2)

                
            case "FaceTime":
                HStack {
                    textInput(label: "2874190573", binding: $textField1)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.box)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }

                
            case "Wi-Fi network":
                HStack {
                    Text("SSID :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "Your SSID", binding: $textField1)
                }
                HStack {
                    Text("Password :")
                        .font(.custom("SF Pro Display", size: 18))
                        .foregroundColor(.black)
                    textInput(label: "Your password", binding: $textField2)
                }

                
            case "Bluetooth":
                VStack {
                    HStack {
                        Text("MAC Address")
                            .font(.custom("SF Pro Display", size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    textInput(label: "C6:90:A4:EA:C3:F1", binding: $textField1)
                        .keyboardType(.asciiCapable)
                }

            
                
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func textInput(label: String, binding: Binding<String>) -> some View {
        VStack() {
            TextField("", text: binding, prompt: Text(label).foregroundColor(.black.opacity(0.1)))
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .foregroundColor(.black.opacity(0.8))
                .disableAutocorrection(true)
        }
    }
    
    private func textTextInput(label: String, binding: Binding<String>) -> some View {
        TextEditor(text: binding)
            .frame(height: 190)
            .padding(8)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .foregroundColor(.black.opacity(0.8))
            .disableAutocorrection(true)
            .scrollContentBackground(.hidden)
            .overlay(
                Group {
                    if binding.wrappedValue.isEmpty {
                        Text(label)
                            .foregroundColor(.black.opacity(0.1))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                },
                alignment: .topLeading
            )
    }
    
    private func writeToTag() {
        let message: NFCNDEFMessage?
        
        switch title {
        case "Text":
            message = NFCWriter.makeTextRecord(textField1)
        case "URL":
            message = NFCWriter.makeURLRecord(textField1)
        case "Phone Number":
            message = NFCWriter.makeURIRecord("tel:\(textField1)")
        case "Contact":
            message = NFCWriter.makeContactRecord(name: textField1, company: textField2, address: textField3, phone: textField4, mail: textField5, website: textField6)
        case "SMS":
            message = NFCWriter.makeURIRecord("sms:\(textField1)?body=\(textField2)")
        case "Email":
            message = NFCWriter.makeEmailRecord(to: textField1, object: textField2, message: textField3)
        case "FaceTime":
            message = NFCWriter.makeURIRecord("facetime:\(textField1)")
        case "Wi-Fi network":
            let payload = "SSID:\(textField1)\nPassword:\(textField2)"
            message = NFCWriter.makeTextRecord(payload)
        case "Bluetooth":
            message = NFCWriter.makeTextRecord("Bluetooth MAC: \(textField1)")
        default:
            message = nil
        }
        
        guard let message = message else {
            writeStatus = "Invalid data."
            return
        }
        
        isWriting = true
        writeStatus = "Ready to write..."
        
        nfcWriter = NFCWriter(message: message)
        nfcWriter?.onComplete = { success, error in
            DispatchQueue.main.async {
                self.isWriting = false
                if success {
                    self.writeStatus = "✅ Tag written successfully!"
                } else if let error = error, error.contains("Tag not writable") || error.contains("not supported") {
                    // Fallback: Use raw writer if NDEF fails
                    let rawData = Array(message.records.first?.payload ?? Data())
                    let padded = rawData + Array(repeating: 0x00, count: (4 - (rawData.count % 4)) % 4)
                    let rawWriter = NFCRawWriter(data: padded)
                    rawWriter.onComplete = { rawSuccess, rawError in
                        DispatchQueue.main.async {
                            self.writeStatus = rawSuccess ? "✅ Raw write successful!" : "❌ Raw write failed: \(rawError ?? "")"
                        }
                    }
                    rawWriter.beginWriting()
                } else {
                    self.writeStatus = "❌ Write failed: \(error ?? "Unknown error")"
                }
            }
        }
        
        nfcWriter?.beginWriting()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
