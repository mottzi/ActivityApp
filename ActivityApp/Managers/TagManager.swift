import SwiftUI

@MainActor
@Observable class TagManager
{
    var allTags: [OSMTag] = OSMTag.allTags
    var currentTag: OSMTag?
    
    public func toggleTag(tag: OSMTag)
    {
        guard let index = allTags.firstIndex(of: tag) else
        {
            return TagManagerError.print(.ToggleTagButtonNotFoundError)
        }
        
        allTags[index].isSelected.toggle()
        
        self.sortTags()
    }
    
    public func sortTags()
    {
        withAnimation(.spring(duration: 0.6))
        {
            self.allTags.sort { $0.isSelected && !$1.isSelected }
        }
    }
    
    public func scrollToFirst()
    {
        guard let currentTag else { return }
        guard currentTag != self.allTags.first else { return }
        
        withAnimation(.easeOut(duration: 10))
        {
            self.currentTag = self.allTags.first
        }
    }
}

extension TagManager
{
    enum TagManagerError: String
    {
        case ToggleTagButtonNotFoundError
        
        static func print(_ error: TagManagerError)
        {
            switch error
            {
                case .ToggleTagButtonNotFoundError: Swift.print("[error] TagManager\(error.rawValue): Tag was not found.")
            }
        }
    }
}
