import Foundation

class HomeViewModel: ObservableObject {
    @Published var accountTypes: [AccountTypeInfo] = AccountTypeInfo.browsableTypes
}
