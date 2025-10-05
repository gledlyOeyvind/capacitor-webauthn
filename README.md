# capacitor-webauthn

WebAuthn authentication plugin for capacitor on ios and android

## Install

```bash
npm install capacitor-webauthn
npx cap sync
```

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
