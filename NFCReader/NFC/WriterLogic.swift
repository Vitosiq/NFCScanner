import SwiftUI
import CoreNFC
// MARK: - SceneDelegate writer
class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    private var message: NFCNDEFMessage
    var onComplete: ((Bool, String?) -> Void)?
    
    init(message: NFCNDEFMessage) {
        self.message = message
    }
    
    func beginWriting() {
        guard NFCNDEFReaderSession.readingAvailable else {
            onComplete?(false, "NFC not supported on this device")
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near an NFC tag to write."
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        onComplete?(false, error.localizedDescription)
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session became active")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        session.connect(to: tag) { error in
            if let error = error {
                self.onComplete?(false, error.localizedDescription)
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    self.onComplete?(false, error.localizedDescription)
                    session.invalidate()
                    return
                }
                
                guard status == .readWrite else {
                    self.onComplete?(false, "Tag not writable.")
                    session.invalidate()
                    return
                }
                
                tag.writeNDEF(self.message) { error in
                    if let error = error {
                        self.onComplete?(false, error.localizedDescription)
                    } else {
                        self.onComplete?(true, nil)
                    }
                    session.invalidate()
                }
            }
        }
    }
}

extension NFCWriter {
    static func makeTextRecord(_ text: String) -> NFCNDEFMessage {
        let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: text, locale: .current)!
        return NFCNDEFMessage(records: [payload])
    }
    
    static func makeURLRecord(_ url: String) -> NFCNDEFMessage {
        guard let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: url) else {
            return makeTextRecord("Invalid URL")
        }
        return NFCNDEFMessage(records: [payload])
    }
    
    static func makeURIRecord(_ uri: String) -> NFCNDEFMessage {
        guard let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: uri) else {
            return makeTextRecord("Invalid URI")
        }
        return NFCNDEFMessage(records: [payload])
    }
    
    static func makeContactRecord(name: String, company: String, address: String, phone: String, mail: String, website: String) -> NFCNDEFMessage {
        let vCard = """
        Name:\(name)
        Company:\(company)
        Address:\(address)
        Phone:\(phone)
        Mail:\(mail)
        Website:\(website)        
        """
        let data = vCard.data(using: .utf8)!
        let payload = NFCNDEFPayload(format: .media, type: "text/x-vCard".data(using: .utf8)!, identifier: Data(), payload: data)
        return NFCNDEFMessage(records: [payload])
    }
    
    static func makeEmailRecord(to: String, object: String, message: String) -> NFCNDEFMessage {
        let vCard = """
        To:\(to)
        Object:\(object)
        Message:\(message)
        """
        let data = vCard.data(using: .utf8)!
        let payload = NFCNDEFPayload(format: .media, type: "text/x-vCard".data(using: .utf8)!, identifier: Data(), payload: data)
        return NFCNDEFMessage(records: [payload])
    }
}


class NFCRawWriter: NSObject, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    private var dataToWrite: [UInt8]
    private var startPage: UInt8
    var onComplete: ((Bool, String?) -> Void)?
    
    init(data: [UInt8], startPage: UInt8 = 4) {
        self.dataToWrite = data
        self.startPage = startPage
        super.init()
    }
    
    func beginWriting() {
        guard NFCTagReaderSession.readingAvailable else {
            onComplete?(false, "NFC not supported on this device.")
            return
        }
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your iPhone near the NFC tag to write raw data."
        session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        onComplete?(false, error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                self.onComplete?(false, error.localizedDescription)
                return
            }
            
            switch tag {
            case .miFare(let mifareTag):
                self.writeRaw(to: mifareTag, in: session)
            default:
                session.invalidate(errorMessage: "Unsupported tag type.")
                self.onComplete?(false, "Unsupported tag type.")
            }
        }
    }
    
    private func writeRaw(to tag: NFCMiFareTag, in session: NFCTagReaderSession) {
        let pageSize = 4
        guard dataToWrite.count % pageSize == 0 else {
            session.invalidate(errorMessage: "Data must be multiple of 4 bytes.")
            self.onComplete?(false, "Data must be multiple of 4 bytes.")
            return
        }
        
        var currentPage = startPage
        let totalPages = dataToWrite.count / pageSize
        
        func writeNext() {
            if currentPage - startPage >= totalPages {
                session.alertMessage = "Data written successfully!"
                session.invalidate()
                self.onComplete?(true, nil)
                return
            }
            
            let startIndex = Int(currentPage - startPage) * pageSize
            let bytes = Array(dataToWrite[startIndex..<startIndex + pageSize])
            let command: [UInt8] = [0xA2, currentPage] + bytes
            
            tag.sendMiFareCommand(commandPacket: Data(command)) { _, error in
                if let error = error {
                    session.invalidate(errorMessage: "Write failed on page \(currentPage): \(error.localizedDescription)")
                    self.onComplete?(false, "Write failed on page \(currentPage): \(error.localizedDescription)")
                    return
                }
                
                print("✅ Wrote page \(currentPage): \(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))")
                currentPage += 1
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.05, execute: writeNext)
            }
        }
        
        writeNext()
    }
}

