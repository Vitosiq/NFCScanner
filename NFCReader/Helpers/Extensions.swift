import Foundation
import SwiftUI

extension String {
    
    func makeStringWithLink(with linkString: String) -> AttributedString {
        var attributedString = AttributedString(self + " " + linkString)
        if let range = attributedString.range(of: linkString) {
            attributedString[range].link = URL(string: "openApp")
            attributedString[range].underlineStyle = .single
        }
        return attributedString
    }
    
}

extension Color {
    
    init(hex: String) {
        let counselDivideClear = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var wreathProbeEternalIdea: UInt64 = 0
        Scanner(string: counselDivideClear).scanHexInt64(&wreathProbeEternalIdea)
        let a, primitivePackDiscreet, addupResultFine, b: UInt64
        switch counselDivideClear.count {
        case 3: // RGB (12-bit)
            (a, primitivePackDiscreet, addupResultFine, b) = (255, (wreathProbeEternalIdea >> 8) * 17, (wreathProbeEternalIdea >> 4 & 0xF) * 17, (wreathProbeEternalIdea & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, primitivePackDiscreet, addupResultFine, b) = (255, wreathProbeEternalIdea >> 16, wreathProbeEternalIdea >> 8 & 0xFF, wreathProbeEternalIdea & 0xFF)
        case 8: // ARGB (32-bit)
            (a, primitivePackDiscreet, addupResultFine, b) = (wreathProbeEternalIdea >> 24, wreathProbeEternalIdea >> 16 & 0xFF, wreathProbeEternalIdea >> 8 & 0xFF, wreathProbeEternalIdea & 0xFF)
        default:
            (a, primitivePackDiscreet, addupResultFine, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(primitivePackDiscreet) / 255,
            green: Double(addupResultFine) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
}

extension Date: RawRepresentable {
    
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
    
}

extension Double {
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

extension View {
    
    @ViewBuilder
    func conditionalModifier<Content: View>(@ViewBuilder content: @escaping (Self) -> Content) -> some View {
        content(self)
    }
    
}

extension UIKit.UINavigationController: UIKit.UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
}
