import Foundation
import Combine
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Monitors system pasteboard for changes on both macOS and iOS
final class PasteboardMonitor: ObservableObject {
    @Published var latestContent: String?

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let checkInterval: TimeInterval = 0.5

    init() {
        #if os(macOS)
        lastChangeCount = NSPasteboard.general.changeCount
        #else
        lastChangeCount = UIPasteboard.general.changeCount
        #endif
    }

    func startMonitoring() {
        stopMonitoring()

        #if os(macOS)
        lastChangeCount = NSPasteboard.general.changeCount
        #else
        lastChangeCount = UIPasteboard.general.changeCount
        #endif

        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }

        #if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        #endif
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkPasteboard() {
        #if os(macOS)
        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if let string = NSPasteboard.general.string(forType: .string) {
            DispatchQueue.main.async { [weak self] in
                self?.latestContent = string
            }
        }
        #else
        let currentCount = UIPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if UIPasteboard.general.hasStrings, let string = UIPasteboard.general.string {
            DispatchQueue.main.async { [weak self] in
                self?.latestContent = string
            }
        }
        #endif
    }

    #if os(iOS)
    @objc private func appBecameActive() {
        checkPasteboard()
    }
    #endif

    deinit {
        stopMonitoring()
        #if os(iOS)
        NotificationCenter.default.removeObserver(self)
        #endif
    }
}
