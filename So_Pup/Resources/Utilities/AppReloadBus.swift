import Combine
import Foundation
//
// An app-wide “reload signal”. When you call `reload()`, it publishes a new
// value on `tick`, which any screen or view model can observe to re-fetch data,
// re-run initialization, or otherwise refresh state. This avoids trying to
// “restart” the app after significant changes (e.g., switching dog mode).
//

@MainActor
final class AppReloadBus: ObservableObject {
    @Published private(set) var tick = UUID()
    func reload() { tick = UUID() }
}

