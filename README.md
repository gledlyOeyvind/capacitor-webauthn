# capacitor-webauthn

A Capacitor plugin that enables WebAuthn (passkeys) authentication on iOS and Android using native platform APIs.

## Features

- ✅ **Native passkey support** - Uses ASAuthorization (iOS) and Credential Manager (Android)
- 🔐 **Secure biometric authentication** - Face ID, Touch ID, fingerprint, etc.
- 🌐 **Web fallback** - Standard WebAuthn API on web platform
- 📱 **Cross-platform** - Works on iOS 16+, Android 9+, and modern browsers
- 🎯 **Type-safe** - Full TypeScript support with detailed interfaces

## What are Passkeys?

Passkeys are a modern, phishing-resistant replacement for passwords based on the WebAuthn standard. They use public-key cryptography and are stored securely on the device, synced via iCloud Keychain (iOS) or Google Password Manager (Android).

## Install

```bash
npm install capacitor-webauthn
npx cap sync
```

## Platform Requirements

### iOS
- iOS 16.0 or later
- Xcode 14 or later
- No additional configuration needed

### Android
- Android 9 (API 28) or later
- Google Play Services
- Credential Manager dependency (included automatically)

## Usage

### Import the plugin

```typescript
import { WebAuthn } from 'capacitor-webauthn';
```

### Check availability

```typescript
const { available } = await WebAuthn.isAvailable();
if (!available) {
  console.log('WebAuthn not supported on this device');
}
```

### Registration (Creating a passkey)

```typescript
try {
  const credential = await WebAuthn.startRegistration({
    challenge: 'base64url-encoded-challenge-from-server',
    rp: {
      name: 'My App',
      id: 'example.com'
    },
    user: {
      id: 'base64url-encoded-user-id',
      name: 'user@example.com',
      displayName: 'John Doe'
    },
    pubKeyCredParams: [
      { type: 'public-key', alg: -7 },  // ES256
      { type: 'public-key', alg: -257 } // RS256
    ],
    authenticatorSelection: {
      authenticatorAttachment: 'platform',
      residentKey: 'required',
      userVerification: 'required'
    },
    timeout: 60000,
    attestation: 'none'
  });

  // Send credential to your server for verification
  console.log('Credential created:', credential);
} catch (error) {
  console.error('Registration failed:', error);
}
```

### Authentication (Signing in with a passkey)

```typescript
try {
  const credential = await WebAuthn.startAuthentication({
    challenge: 'base64url-encoded-challenge-from-server',
    rpId: 'example.com',
    timeout: 60000,
    userVerification: 'required'
  });

  // Send credential to your server for verification
  console.log('Authentication successful:', credential);
} catch (error) {
  console.error('Authentication failed:', error);
}
```

## Server Integration

This plugin handles the client-side WebAuthn flow. You'll need a server that:

1. Generates challenges for registration and authentication
2. Verifies the credential responses
3. Stores public keys associated with user accounts

**Recommended libraries:**
- Node.js: [@simplewebauthn/server](https://github.com/MasterKale/SimpleWebAuthn)
- Python: [py_webauthn](https://github.com/duo-labs/py_webauthn)
- Go: [webauthn](https://github.com/go-webauthn/webauthn)
- Java: [webauthn4j](https://github.com/webauthn4j/webauthn4j)

## Error Handling

Common errors you might encounter:

- **"WebAuthn not available"** - Device doesn't support passkeys or is too old
- **"User cancelled"** - User dismissed the authentication prompt
- **"No passkey providers available"** - Android device doesn't have Google Play Services
- **"Invalid challenge"** - Challenge format is incorrect (must be base64url)

## API

<docgen-index>

* [`isAvailable()`](#isavailable)
* [`startRegistration(...)`](#startregistration)
* [`startAuthentication(...)`](#startauthentication)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### isAvailable()

```typescript
isAvailable() => Promise<{ available: boolean; }>
```

Check if WebAuthn is available on this device

**Returns:** <code>Promise&lt;{ available: boolean; }&gt;</code>

--------------------


### startRegistration(...)

```typescript
startRegistration(options: StartRegistrationOptions) => Promise<RegistrationCredential>
```

Start registration (credential creation) flow

| Param         | Type                                                                          |
| ------------- | ----------------------------------------------------------------------------- |
| **`options`** | <code><a href="#startregistrationoptions">StartRegistrationOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#registrationcredential">RegistrationCredential</a>&gt;</code>

--------------------


### startAuthentication(...)

```typescript
startAuthentication(options: StartAuthenticationOptions) => Promise<AuthenticationCredential>
```

Start authentication flow

| Param         | Type                                                                              |
| ------------- | --------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#startauthenticationoptions">StartAuthenticationOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#authenticationcredential">AuthenticationCredential</a>&gt;</code>

--------------------


### Interfaces


#### RegistrationCredential

| Prop                          | Type                                                                |
| ----------------------------- | ------------------------------------------------------------------- |
| **`id`**                      | <code>string</code>                                                 |
| **`rawId`**                   | <code>string</code>                                                 |
| **`response`**                | <code>{ clientDataJSON: string; attestationObject: string; }</code> |
| **`type`**                    | <code>'public-key'</code>                                           |
| **`authenticatorAttachment`** | <code>'platform' \| 'cross-platform'</code>                         |


#### StartRegistrationOptions

| Prop                         | Type                                                                                      |
| ---------------------------- | ----------------------------------------------------------------------------------------- |
| **`challenge`**              | <code>string</code>                                                                       |
| **`rp`**                     | <code><a href="#publickeycredentialrpentity">PublicKeyCredentialRpEntity</a></code>       |
| **`user`**                   | <code><a href="#publickeycredentialuserentity">PublicKeyCredentialUserEntity</a></code>   |
| **`pubKeyCredParams`**       | <code>PublicKeyCredentialParameters[]</code>                                              |
| **`timeout`**                | <code>number</code>                                                                       |
| **`excludeCredentials`**     | <code>PublicKeyCredentialDescriptor[]</code>                                              |
| **`authenticatorSelection`** | <code><a href="#authenticatorselectioncriteria">AuthenticatorSelectionCriteria</a></code> |
| **`attestation`**            | <code>'none' \| 'indirect' \| 'direct' \| 'enterprise'</code>                             |


#### PublicKeyCredentialRpEntity

| Prop       | Type                |
| ---------- | ------------------- |
| **`id`**   | <code>string</code> |
| **`name`** | <code>string</code> |


#### PublicKeyCredentialUserEntity

| Prop              | Type                |
| ----------------- | ------------------- |
| **`id`**          | <code>string</code> |
| **`name`**        | <code>string</code> |
| **`displayName`** | <code>string</code> |


#### PublicKeyCredentialParameters

| Prop       | Type                      |
| ---------- | ------------------------- |
| **`type`** | <code>'public-key'</code> |
| **`alg`**  | <code>number</code>       |


#### PublicKeyCredentialDescriptor

| Prop             | Type                                                   |
| ---------------- | ------------------------------------------------------ |
| **`type`**       | <code>'public-key'</code>                              |
| **`id`**         | <code>string</code>                                    |
| **`transports`** | <code>('usb' \| 'nfc' \| 'ble' \| 'internal')[]</code> |


#### AuthenticatorSelectionCriteria

| Prop                          | Type                                                    |
| ----------------------------- | ------------------------------------------------------- |
| **`authenticatorAttachment`** | <code>'platform' \| 'cross-platform'</code>             |
| **`requireResidentKey`**      | <code>boolean</code>                                    |
| **`residentKey`**             | <code>'discouraged' \| 'preferred' \| 'required'</code> |
| **`userVerification`**        | <code>'discouraged' \| 'preferred' \| 'required'</code> |


#### AuthenticationCredential

| Prop                          | Type                                                                                                        |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------- |
| **`id`**                      | <code>string</code>                                                                                         |
| **`rawId`**                   | <code>string</code>                                                                                         |
| **`response`**                | <code>{ clientDataJSON: string; authenticatorData: string; signature: string; userHandle?: string; }</code> |
| **`type`**                    | <code>'public-key'</code>                                                                                   |
| **`authenticatorAttachment`** | <code>'platform' \| 'cross-platform'</code>                                                                 |


#### StartAuthenticationOptions

| Prop                   | Type                                                    |
| ---------------------- | ------------------------------------------------------- |
| **`challenge`**        | <code>string</code>                                     |
| **`timeout`**          | <code>number</code>                                     |
| **`rpId`**             | <code>string</code>                                     |
| **`allowCredentials`** | <code>PublicKeyCredentialDescriptor[]</code>            |
| **`userVerification`** | <code>'discouraged' \| 'preferred' \| 'required'</code> |

</docgen-api>

## Security Considerations

- Always validate credentials on your server - never trust client responses alone
- Use challenges that are cryptographically random and single-use
- Implement rate limiting to prevent brute force attacks
- Store only public keys on your server (private keys never leave the device)
- Use HTTPS for all WebAuthn operations (required by the standard)

## Browser and Platform Support

| Platform | Minimum Version | Notes |
|----------|----------------|-------|
| iOS | 16.0 | Uses ASAuthorization framework |
| Android | 9.0 (API 28) | Requires Google Play Services |
| Web | Modern browsers | Falls back to standard WebAuthn API |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT © [Øyvind Berget](https://github.com/gledlyOeyvind)

## Links

- [GitHub Repository](https://github.com/gledlyOeyvind/capacitor-webauthn)
- [Report Issues](https://github.com/gledlyOeyvind/capacitor-webauthn/issues)
- [WebAuthn Guide](https://webauthn.guide/)
- [Passkeys.dev](https://passkeys.dev/)
