//
//  A lightweight “event bus” used to trigger global reloads in the app.
//  Exposes a published `tick` value that changes whenever `reload()` is called.
//  Views or view models observing `tick` can respond by refreshing their data.
//
//  Key Responsibilities:
//  - Provide a central, observable way to broadcast reload requests
//  Calling reload() updates `tick`, which notifies all views
//  using `.onReceive(reloadBus.$tick)` so they can refresh data.
//
//  Usage:
//  Inject as an @EnvironmentObject. Call `reloadBus.reload()` from anywhere,
//  and handle reloads in `.onReceive(reloadBus.$tick)` in RootView or other
//  listeners.
//
//  Note:
//  tick is a signal, not user data.
//  It says "something happened, time to reload"
import Combine
import Foundation

@MainActor
final class AppReloadBus: ObservableObject {
    @Published private(set) var tick = UUID()
    
    /// Triggers a reload by updating the tick value
    func reload() { tick = UUID() }
}
