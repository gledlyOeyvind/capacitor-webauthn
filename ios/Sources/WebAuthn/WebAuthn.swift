import Foundation
import AuthenticationServices

@available(iOS 15.0, *)
@objc public class WebAuthn: NSObject {

    private var authorizationController: ASAuthorizationController?
    private var continuationRegistration: CheckedContinuation<RegistrationResult, Error>?
    private var continuationAuthentication: CheckedContinuation<AuthenticationResult, Error>?

    public struct RegistrationResult {
        let credentialId: Data
        let attestationObject: Data
        let clientDataJSON: Data
    }

    public struct AuthenticationResult {
        let credentialId: Data
        let authenticatorData: Data
        let signature: Data
        let userHandle: Data?
        let clientDataJSON: Data
    }

    @objc public func isAvailable() -> Bool {
        if #available(iOS 15.0, *) {
            return true
        }
        return false
    }

    public func startRegistration(
        challenge: Data,
        rpId: String,
        rpName: String,
        userId: Data,
        userName: String,
        userDisplayName: String,
        timeout: Int?,
        pubKeyCredParams: [[String: Any]],
        excludeCredentials: [[String: Any]]?,
        authenticatorSelection: [String: Any]?,
        attestation: String?
    ) async throws -> RegistrationResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuationRegistration = continuation

            let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)

            let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(
                challenge: challenge,
                name: userName,
                userID: userId
            )

            // Set user verification preference
            if let authSelection = authenticatorSelection,
               let userVerification = authSelection["userVerification"] as? String {
                switch userVerification {
                case "required":
                    registrationRequest.userVerificationPreference = .required
                case "preferred":
                    registrationRequest.userVerificationPreference = .preferred
                case "discouraged":
                    registrationRequest.userVerificationPreference = .discouraged
                default:
                    registrationRequest.userVerificationPreference = .preferred
                }
            }

            let authController = ASAuthorizationController(authorizationRequests: [registrationRequest])
            authController.delegate = self
            authController.presentationContextProvider = self
            self.authorizationController = authController

            DispatchQueue.main.async {
                authController.performRequests()
            }
        }
    }

    public func startAuthentication(
        challenge: Data,
        rpId: String,
        timeout: Int?,
        allowCredentials: [[String: Any]]?,
        userVerification: String?
    ) async throws -> AuthenticationResult {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuationAuthentication = continuation

            let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)

            let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)

            // Set allowed credentials if provided
            if let allowedCreds = allowCredentials, !allowedCreds.isEmpty {
                let credentialIds = allowedCreds.compactMap { cred -> Data? in
                    guard let idString = cred["id"] as? String else { return nil }
                    return Data(base64URLEncoded: idString)
                }
                if !credentialIds.isEmpty {
                    assertionRequest.allowedCredentials = credentialIds.map {
                        ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: $0)
                    }
                }
            }

            // Set user verification preference
            if let userVerif = userVerification {
                switch userVerif {
                case "required":
                    assertionRequest.userVerificationPreference = .required
                case "preferred":
                    assertionRequest.userVerificationPreference = .preferred
                case "discouraged":
                    assertionRequest.userVerificationPreference = .discouraged
                default:
                    assertionRequest.userVerificationPreference = .preferred
                }
            }

            let authController = ASAuthorizationController(authorizationRequests: [assertionRequest])
            authController.delegate = self
            authController.presentationContextProvider = self
            self.authorizationController = authController

            DispatchQueue.main.async {
                authController.performRequests()
            }
        }
    }
}

@available(iOS 15.0, *)
extension WebAuthn: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // Registration completed
            let result = RegistrationResult(
                credentialId: credential.credentialID,
                attestationObject: credential.rawAttestationObject ?? Data(),
                clientDataJSON: credential.rawClientDataJSON
            )
            continuationRegistration?.resume(returning: result)
            continuationRegistration = nil
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // Authentication completed
            let result = AuthenticationResult(
                credentialId: credential.credentialID,
                authenticatorData: credential.rawAuthenticatorData,
                signature: credential.signature,
                userHandle: credential.userID,
                clientDataJSON: credential.rawClientDataJSON
            )
            continuationAuthentication?.resume(returning: result)
            continuationAuthentication = nil
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let continuation = continuationRegistration {
            continuation.resume(throwing: error)
            continuationRegistration = nil
        } else if let continuation = continuationAuthentication {
            continuation.resume(throwing: error)
            continuationAuthentication = nil
        }
    }
}

@available(iOS 15.0, *)
extension WebAuthn: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

// Base64URL encoding/decoding helpers
extension Data {
    init?(base64URLEncoded: String) {
        var base64 = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Add padding if needed
        let paddingLength = (4 - base64.count % 4) % 4
        base64 += String(repeating: "=", count: paddingLength)

        self.init(base64Encoded: base64)
    }

    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
