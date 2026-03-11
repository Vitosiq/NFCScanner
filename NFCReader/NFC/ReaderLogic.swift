import SwiftUI
import CoreNFC
// MARK: - SceneDelegate Reader
struct TagHardwareInfo: Codable {
    var serialNumber: String
    var atqa: String
    var sak: String
}

struct TagInfo: Codable, Identifiable {
    var id = UUID()
    var tagType: String
    var technologies: [String]
    var memorySize: String
    var writable: Bool
    var dataFormat: String
    var records: [String]
    var hardware: TagHardwareInfo?
}

@MainActor
class NFCReaderViewModel: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var tagInfo: TagInfo?
    @Published var scanError: String?
    @Published var isScanning = false

    private var session: NFCTagReaderSession?

    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            scanError = "NFC is not available on this device."
            return
        }

        isScanning = true
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.alertMessage = "Hold your iPhone near an NFC tag."
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("NFC session active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            self.scanError = error.localizedDescription
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }

            var serial = "-"
            var atqa = "-"
            var sak = "-"
            var tagType = "Unknown"
            var ndefTag: NFCNDEFTag?

            switch tag {
            case .miFare(let miFare):
                serial = miFare.identifier.map { String(format: "%.2hhx", $0) }.joined().uppercased()
                atqa = String(format: "%.2X", miFare.historicalBytes?.first ?? 0)
                sak = String(format: "%.2X", miFare.mifareFamily.rawValue)
                tagType = "MiFare"
                ndefTag = miFare as? NFCNDEFTag
            case .iso15693(let iso):
                serial = iso.identifier.map { String(format: "%.2hhx", $0) }.joined().uppercased()
                tagType = "ISO15693"
                ndefTag = iso as? NFCNDEFTag
            case .iso7816(let iso):
                tagType = "ISO7816"
                ndefTag = iso as? NFCNDEFTag
            case .feliCa(let feliCa):
                tagType = "FeliCa"
                ndefTag = feliCa as? NFCNDEFTag
            @unknown default:
                break
            }

            let hardwareInfo = TagHardwareInfo(serialNumber: serial, atqa: atqa, sak: sak)

            guard let ndef = ndefTag else {
                DispatchQueue.main.async {
                    let newTag = TagInfo(
                        tagType: tagType,
                        technologies: ["Unknown"],
                        memorySize: "Unknown",
                        writable: false,
                        dataFormat: "Raw",
                        records: [],
                        hardware: hardwareInfo
                    )
                    self.tagInfo = newTag
                    self.isScanning = false
                    NFCHistoryManager().saveTag(newTag)
                }
                session.alertMessage = "Non-NDEF tag detected"
                session.invalidate()
                return
            }

            ndef.queryNDEFStatus { status, capacity, error in
                let memSize = capacity > 0 ? "\(capacity) bytes" : "Unknown"

                if status == .notSupported || error != nil {
                    DispatchQueue.main.async {
                        let newTag = TagInfo(
                            tagType: tagType,
                            technologies: ["NDEF not supported"],
                            memorySize: memSize,
                            writable: false,
                            dataFormat: "Raw",
                            records: [],
                            hardware: hardwareInfo
                        )
                        self.tagInfo = newTag
                        self.isScanning = false
                        NFCHistoryManager().saveTag(newTag)
                    }
                    session.alertMessage = "Tag detected but NDEF not supported"
                    session.invalidate()
                    return
                }

                ndef.readNDEF { message, error in
                    var records: [String] = []
                    if let message = message {
                        records = message.records.compactMap { self.parseNDEFRecord($0) }
                    }

                    DispatchQueue.main.async {
                        let newTag = TagInfo(
                            tagType: tagType,
                            technologies: ["NDEF"],
                            memorySize: memSize,
                            writable: status == .readWrite,
                            dataFormat: "NDEF",
                            records: records,
                            hardware: hardwareInfo
                        )
                        self.tagInfo = newTag
                        self.isScanning = false
                        NFCHistoryManager().saveTag(newTag)
                    }

                    session.alertMessage = "Tag read successfully!"
                    session.invalidate()
                }
            }
        }
    }
    
    func parseNDEFRecord(_ record: NFCNDEFPayload) -> String? {
        switch record.typeNameFormat {
        case .nfcWellKnown:
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" {
                    // Use Apple's helper to parse text correctly
                    if let (text, _) = try? record.wellKnownTypeTextPayload() {
                        return text
                    }
                } else if type == "U" {
                    guard record.payload.count > 1 else { return nil }
                    let prefixCode = record.payload.first!
                    let uriData = record.payload.dropFirst(1)
                    let prefix = NFCURIRecordPrefixes[Int(prefixCode)] ?? ""
                    if let uri = String(data: uriData, encoding: .utf8) {
                        return prefix + uri
                    }
                }
            }
            
        case .media, .absoluteURI:
            return String(data: record.payload, encoding: .utf8)

        default:
            return String(data: record.payload, encoding: .utf8)
        }
        
        return nil
    }

    // Helper for URI prefixes
    private let NFCURIRecordPrefixes: [Int: String] = [
        0x00: "",
        0x01: "http://www.",
        0x02: "https://www.",
        0x03: "http://",
        0x04: "https://",
        0x05: "tel:",
        0x06: "mailto:",
        0x07: "ftp://anonymous:anonymous@",
        0x08: "ftp://ftp.",
        0x09: "ftps://",
        0x0A: "sftp://",
        0x0B: "smb://",
        0x0C: "nfs://",
        0x0D: "ftp://",
        0x0E: "dav://",
        0x0F: "news:",
        0x10: "telnet://",
        0x11: "imap:",
        0x12: "rtsp://",
        0x13: "urn:",
        0x14: "pop:",
        0x15: "sip:",
        0x16: "sips:",
        0x17: "tftp:",
        0x18: "btspp://",
        0x19: "btl2cap://",
        0x1A: "btgoep://",
        0x1B: "tcpobex://",
        0x1C: "irdaobex://",
        0x1D: "file://",
        0x1E: "urn:epc:id:",
        0x1F: "urn:epc:tag:",
        0x20: "urn:epc:pat:",
        0x21: "urn:epc:raw:",
        0x22: "urn:epc:",
        0x23: "urn:nfc:"
    ]
    
    func reset() {
        isScanning = false
        tagInfo = nil
        scanError = nil
    }
    
}
