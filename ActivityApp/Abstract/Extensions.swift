import SwiftUI

#if DEBUG
extension View
{
    func debug(_ color: Color = .orange) -> some View
    {
        self
            .border(color, width: 1)
    }
}
#endif

extension Double
{
    var string: String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale.current
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
