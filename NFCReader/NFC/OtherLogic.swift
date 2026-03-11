import Foundation
import CoreNFC
// MARK: - SceneDelegate Other
class NFCManager: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    static let shared = NFCManager()
    
    private var session: NFCTagReaderSession?
    private var pendingAction: NFCAction?
    private var pendingPassword: String?
    
    enum NFCAction {
        case clear
        case block
        case setPassword(String)
        case deletePassword(String)
    }
    
    func perform(_ action: NFCAction) {
        pendingAction = action
        if case let .setPassword(pwd) = action { pendingPassword = pwd }
        if case let .deletePassword(pwd) = action { pendingPassword = pwd }
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC Session active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("Session invalidated: \(error.localizedDescription)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else { return }
        
        session.connect(to: firstTag) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Connection failed: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            guard case let .miFare(tag) = firstTag else {
                session.invalidate(errorMessage: "Unsupported tag type (NTAG213/215/216 required).")
                return
            }
            
            // Identify, then reconnect, then act
            self.identifyTag(tag) {
                // Wait before reconnecting to avoid disconnects
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    session.connect(to: firstTag) { error in
                        if let error = error {
                            session.invalidate(errorMessage: "Reconnect failed: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let action = self.pendingAction else {
                            session.invalidate(errorMessage: "No action specified.")
                            return
                        }
                        
                        // Wait a bit more before actual command
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            switch action {
                            case .clear:
                                self.clearTag(tag, session: session)
                            case .block:
                                self.lockTag(tag, session: session)
                            case .setPassword(let pwd):
                                self.setPassword(tag, password: pwd, session: session)
                            case .deletePassword(let pwd):
                                self.removePassword(tag, password: pwd, session: session)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func clearTag(_ tag: NFCMiFareTag, session: NFCTagReaderSession) {
        print("🧹 Clearing tag...")
        let emptyData = Data([0x03, 0x00, 0xFE])
        let cmd: [UInt8] = [0xA2, 4] + [UInt8](emptyData) + [0x00]
        
        tag.sendMiFareCommand(commandPacket: Data(cmd)) { _, error in
            if let error = error {
                session.invalidate(errorMessage: "Failed to clear: \(error.localizedDescription)")
            } else {
                session.alertMessage = "✅ Tag cleared successfully."
                session.invalidate()
            }
        }
    }
    
    private func lockTag(_ tag: NFCMiFareTag, session: NFCTagReaderSession) {
        print("🔒 Locking tag...")
        let cmd: [UInt8] = [0xA2, 0x02, 0x00, 0x00, 0x0F, 0xE0]
        tag.sendMiFareCommand(commandPacket: Data(cmd)) { _, error in
            if let error = error {
                session.invalidate(errorMessage: "Failed to lock: \(error.localizedDescription)")
            } else {
                session.alertMessage = "🔒 Tag locked (read-only)."
                session.invalidate()
            }
        }
    }

    private func setPassword(_ tag: NFCMiFareTag, password: String, session: NFCTagReaderSession) {
        print("Setting password...")

        let pwd = Array(password.utf8.prefix(4)) + Array(repeating: 0x00, count: max(0, 4 - password.count))
        let pack: [UInt8] = [0x12, 0x34]

        self.writePageWithDelay(tag, page: 0xE5, bytes: pwd, session: session) { success in
            guard success else { return }

            self.authenticate(tag, password: password) { authSuccess in
                guard authSuccess else {
                    session.invalidate(errorMessage: "Authentication failed after setting password.")
                    return
                }

                self.writePageWithDelay(tag, page: 0xE6, bytes: pack + [0x00, 0x00], session: session) { success in
                    guard success else { return }

                    self.writePageWithDelay(tag, page: 0xE3, bytes: [0x04, 0x00, 0x00, 0x00], session: session) { success in
                        guard success else { return }

                        // Step 5: Set AUTH0 to E4 (enable protection)
                        self.writePageWithDelay(tag, page: 0xE4, bytes: [0x80, 0x00, 0x00, 0x00], session: session) { success in
                            if success {
                                session.alertMessage = "Password set successfully."
                                session.invalidate()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func writePageWithDelay(_ tag: NFCMiFareTag,
                                    page: UInt8,
                                    bytes: [UInt8],
                                    session: NFCTagReaderSession,
                                    retries: Int = 1,
                                    delay: TimeInterval = 0.5,
                                    completion: @escaping (Bool) -> Void) {
        let cmd: [UInt8] = [0xA2, page] + bytes.prefix(4)

        print("📤 Writing to page \(page):", cmd.map { String(format: "%02X", $0) }.joined(separator: " "))

        tag.sendMiFareCommand(commandPacket: Data(cmd)) { _, error in
            if let error = error {
                print("❌ Write to page \(page) failed: \(error.localizedDescription)")

                if retries > 0 {
                    print("🔁 Retrying page \(page)... (\(retries) left)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.writePageWithDelay(tag,
                                                page: page,
                                                bytes: bytes,
                                                session: session,
                                                retries: retries - 1,
                                                delay: delay,
                                                completion: completion)
                    }
                } else {
                    session.invalidate(errorMessage: "Write failed (page \(page)): \(error.localizedDescription)")
                    completion(false)
                }
            } else {
                print("✅ Successfully wrote page \(page)")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    completion(true)
                }
            }
        }
    }
    
    private func log(_ message: String) {
        print("[NFCManager] \(message)")
    }
    
    
    
    private func removePassword(_ tag: NFCMiFareTag, password: String, session: NFCTagReaderSession) {
        print("🔓 Removing password...")
        authenticate(tag, password: password) { success in
            guard success else {
                session.invalidate(errorMessage: "❌ Wrong password.")
                return
            }
            
            self.writePage(tag, page: 0xE3, bytes: [0xFF, 0x00, 0x00, 0x00], session: session) { success in
                if success {
                    session.alertMessage = "✅ Password removed."
                    session.invalidate()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func authenticate(_ tag: NFCMiFareTag, password: String, completion: @escaping (Bool) -> Void) {
        let pwdBytes = Array(password.utf8.prefix(4)) + Array(repeating: 0x00, count: max(0, 4 - password.count))
        var command: [UInt8] = [0x1B]
        command.append(contentsOf: pwdBytes)
        
        tag.sendMiFareCommand(commandPacket: Data(command)) { response, error in
            if error == nil && response.count >= 2 {
                print("PACK:", response as NSData)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func writePage(_ tag: NFCMiFareTag, page: UInt8, bytes: [UInt8],
                           session: NFCTagReaderSession,
                           completion: @escaping (Bool) -> Void) {
        var cmd: [UInt8] = [0xA2, page]
        cmd.append(contentsOf: bytes.prefix(4))
        
        tag.sendMiFareCommand(commandPacket: Data(cmd)) { _, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if let error = error {
                    session.invalidate(errorMessage: "Write failed (page \(page)): \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    private func identifyTag(_ tag: NFCMiFareTag, completion: @escaping () -> Void) {
        print("🔍 Identifying tag...")
        
        func tryReadPage0(retries: Int = 2) {
            tag.sendMiFareCommand(commandPacket: Data([0x30, 0x00])) { data, error in
                if let error = error {
                    print("Identify (0x30) failed:", error.localizedDescription)
                    if retries > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            tryReadPage0(retries: retries - 1)
                        }
                    } else {
                        completion()
                    }
                } else {
                    print("✅ Page 0 data:", data as NSData)
                    completion()
                }
            }
        }
        
        tag.sendMiFareCommand(commandPacket: Data([0x60])) { response, error in
            if let error = error {
                print("Identify (0x60) failed:", error.localizedDescription)
            } else {
                print("ATQA/SAK:", response as NSData)
            }
            tryReadPage0()
        }
    }
}
