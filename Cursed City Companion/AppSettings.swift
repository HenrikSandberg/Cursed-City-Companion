import Foundation
import Combine

final class AppSettings: ObservableObject {
    @Published var decapStrictRules: Bool = true
}
