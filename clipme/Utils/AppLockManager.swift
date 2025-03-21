//
//  AppLockManager.swift
//  clipme
//
//  Created by AlexDelgado on 21/3/25.
//


import Foundation
import LocalAuthentication
import Combine
import UIKit

enum BiometricType: String {
    case none = "Código del dispositivo"
    case touchID = "Touch ID"
    case faceID = "Face ID"
}

@MainActor
final class AppLockManager: ObservableObject {
    @Published var isUnlocked = false
    @Published var errorMessage: String?
    @Published var biometricType: BiometricType = .none

    private var autoLockTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let autoLockSeconds: TimeInterval

    init(autoLockSeconds: TimeInterval = 60) {
        self.autoLockSeconds = autoLockSeconds
        detectBiometricType()
        observeAppLifecycle()
    }

    // MARK: - Auth

    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Fallback to passcode if biometrics are unavailable
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            errorMessage = error?.localizedDescription ?? "No se puede autenticar este dispositivo."
            isUnlocked = false
            return false
        }

        let reason = "Autentícate con \(biometricType.rawValue) para continuar"

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if success {
                isUnlocked = true
                errorMessage = nil
                startAutoLockTimer()
                return true
            } else {
                errorMessage = "Fallo de autenticación"
                isUnlocked = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isUnlocked = false
            return false
        }
    }

    func lock() {
        isUnlocked = false
        cancelAutoLockTimer()
    }

    // MARK: - Biometric Detection

    private func detectBiometricType() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            biometricType = .none
            return
        }

        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        default:
            biometricType = .none
        }
    }

    // MARK: - Auto-lock

    private func startAutoLockTimer() {
        cancelAutoLockTimer()
        autoLockTask = Task {
            try? await Task.sleep(for: .seconds(autoLockSeconds))
            lock()
            print("🔒 Auto-locked after \(autoLockSeconds) seconds.")
        }
    }

    private func cancelAutoLockTimer() {
        autoLockTask?.cancel()
        autoLockTask = nil
    }

    // MARK: - Lifecycle

    private func observeAppLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.lock()
                    print("🔒 App moved to background – locked")
                }
            }
            .store(in: &cancellables)
    }
}
