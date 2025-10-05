import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(WebAuthnPlugin)
public class WebAuthnPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "WebAuthnPlugin"
    public let jsName = "WebAuthn"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isAvailable", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startRegistration", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startAuthentication", returnType: CAPPluginReturnPromise)
    ]

    private var implementation: WebAuthn?

    public override func load() {
        if #available(iOS 15.0, *) {
            implementation = WebAuthn()
        }
    }

    @objc func isAvailable(_ call: CAPPluginCall) {
        if #available(iOS 15.0, *) {
            call.resolve([
                "available": implementation?.isAvailable() ?? false
            ])
        } else {
            call.resolve([
                "available": false
            ])
        }
    }

    @objc func startRegistration(_ call: CAPPluginCall) {
        guard #available(iOS 15.0, *), let impl = implementation else {
            call.reject("WebAuthn is not available on this device (iOS 15.0+ required)")
            return
        }

        guard let challengeString = call.getString("challenge"),
              let challenge = Data(base64URLEncoded: challengeString) else {
            call.reject("Invalid challenge")
            return
        }

        guard let rp = call.getObject("rp"),
              let rpName = rp["name"] as? String else {
            call.reject("Invalid rp")
            return
        }
        let rpId = rp["id"] as? String ?? ""

        guard let user = call.getObject("user"),
              let userIdString = user["id"] as? String,
              let userId = Data(base64URLEncoded: userIdString),
              let userName = user["name"] as? String,
              let userDisplayName = user["displayName"] as? String else {
            call.reject("Invalid user")
            return
        }

        let pubKeyCredParams = call.getArray("pubKeyCredParams", [String: Any].self) ?? []
        let excludeCredentials = call.getArray("excludeCredentials", [String: Any].self)
        let authenticatorSelection = call.getObject("authenticatorSelection")
        let attestation = call.getString("attestation")
        let timeout = call.getInt("timeout")

        Task {
            do {
                let result = try await impl.startRegistration(
                    challenge: challenge,
                    rpId: rpId,
                    rpName: rpName,
                    userId: userId,
                    userName: userName,
                    userDisplayName: userDisplayName,
                    timeout: timeout,
                    pubKeyCredParams: pubKeyCredParams,
                    excludeCredentials: excludeCredentials,
                    authenticatorSelection: authenticatorSelection,
                    attestation: attestation
                )

                call.resolve([
                    "id": result.credentialId.base64URLEncodedString(),
                    "rawId": result.credentialId.base64URLEncodedString(),
                    "response": [
                        "clientDataJSON": result.clientDataJSON.base64URLEncodedString(),
                        "attestationObject": result.attestationObject.base64URLEncodedString()
                    ],
                    "type": "public-key",
                    "authenticatorAttachment": "platform"
                ])
            } catch {
                call.reject("Registration failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func startAuthentication(_ call: CAPPluginCall) {
        guard #available(iOS 15.0, *), let impl = implementation else {
            call.reject("WebAuthn is not available on this device (iOS 15.0+ required)")
            return
        }

        guard let challengeString = call.getString("challenge"),
              let challenge = Data(base64URLEncoded: challengeString) else {
            call.reject("Invalid challenge")
            return
        }

        let rpId = call.getString("rpId") ?? ""
        let timeout = call.getInt("timeout")
        let allowCredentials = call.getArray("allowCredentials", [String: Any].self)
        let userVerification = call.getString("userVerification")

        Task {
            do {
                let result = try await impl.startAuthentication(
                    challenge: challenge,
                    rpId: rpId,
                    timeout: timeout,
                    allowCredentials: allowCredentials,
                    userVerification: userVerification
                )

                var response: [String: Any] = [
                    "clientDataJSON": result.clientDataJSON.base64URLEncodedString(),
                    "authenticatorData": result.authenticatorData.base64URLEncodedString(),
                    "signature": result.signature.base64URLEncodedString()
                ]

                if let userHandle = result.userHandle {
                    response["userHandle"] = userHandle.base64URLEncodedString()
                }

                call.resolve([
                    "id": result.credentialId.base64URLEncodedString(),
                    "rawId": result.credentialId.base64URLEncodedString(),
                    "response": response,
                    "type": "public-key",
                    "authenticatorAttachment": "platform"
                ])
            } catch {
                call.reject("Authentication failed: \(error.localizedDescription)")
            }
        }
    }
}
