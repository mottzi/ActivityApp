import SwiftUI

struct SearchBar: View
{
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText: String = ""
    
    enum Field
    {
        case search
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View
    {
        HStack
        {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .fontWeight(.medium)
                .foregroundStyle(.black.opacity(0.8))
                .padding(.horizontal, 0)
                .padding(.trailing, 4)
            
            TextField("", text: $searchText, prompt: searchPrompt)
                .foregroundStyle(.black.opacity(0.8))
                .font(.title3)
                .fontWeight(.regular)
                .textContentType(.location)
                .keyboardType(.webSearch)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .search)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .background
        {
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        }
        .padding(.horizontal, 16)
        .overlay { extendedHitBox }
        .overlay(alignment: .trailing) { searchClearButton }
    }
    
    var searchClearButton: some View
    {
        Button
        {
            searchText = ""
            focusedField = .search
        }
        label:
        {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .frame(width: 45)
                .frame(maxHeight: .infinity)
                .fontWeight(.medium)
                .contentShape(.rect)
        }
        .padding(.trailing, 22)
        .foregroundStyle(.black.opacity(searchText.isEmpty ? 0 : 0.8))
        .disabled(searchText.isEmpty)
        .transaction { $0.disablesAnimations = true }
    }
    
    var extendedHitBox: some View
    {
        Color.clear
            .contentShape(.rect)
            .onTapGesture { focusedField = .search }
    }
    
    var searchPrompt: Text
    {
        Text("Search here ...")
            .foregroundStyle(.black.opacity(0.5))
    }
}

#Preview
{
    ActivityPickerScreen()
}
