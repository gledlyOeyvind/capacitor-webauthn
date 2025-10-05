export interface PublicKeyCredentialRpEntity {
  id?: string;
  name: string;
}

export interface PublicKeyCredentialUserEntity {
  id: string;
  name: string;
  displayName: string;
}

export interface PublicKeyCredentialParameters {
  type: 'public-key';
  alg: number; // COSE algorithm identifier
}

export interface PublicKeyCredentialDescriptor {
  type: 'public-key';
  id: string; // base64url encoded credential ID
  transports?: ('usb' | 'nfc' | 'ble' | 'internal')[];
}

export interface AuthenticatorSelectionCriteria {
  authenticatorAttachment?: 'platform' | 'cross-platform';
  requireResidentKey?: boolean;
  residentKey?: 'discouraged' | 'preferred' | 'required';
  userVerification?: 'required' | 'preferred' | 'discouraged';
}

export interface StartRegistrationOptions {
  challenge: string; // base64url encoded
  rp: PublicKeyCredentialRpEntity;
  user: PublicKeyCredentialUserEntity;
  pubKeyCredParams: PublicKeyCredentialParameters[];
  timeout?: number;
  excludeCredentials?: PublicKeyCredentialDescriptor[];
  authenticatorSelection?: AuthenticatorSelectionCriteria;
  attestation?: 'none' | 'indirect' | 'direct' | 'enterprise';
}

export interface RegistrationCredential {
  id: string; // base64url encoded credential ID
  rawId: string; // base64url encoded
  response: {
    clientDataJSON: string; // base64url encoded
    attestationObject: string; // base64url encoded
  };
  type: 'public-key';
  authenticatorAttachment?: 'platform' | 'cross-platform';
}

export interface StartAuthenticationOptions {
  challenge: string; // base64url encoded
  timeout?: number;
  rpId?: string;
  allowCredentials?: PublicKeyCredentialDescriptor[];
  userVerification?: 'required' | 'preferred' | 'discouraged';
}

export interface AuthenticationCredential {
  id: string; // base64url encoded credential ID
  rawId: string; // base64url encoded
  response: {
    clientDataJSON: string; // base64url encoded
    authenticatorData: string; // base64url encoded
    signature: string; // base64url encoded
    userHandle?: string; // base64url encoded
  };
  type: 'public-key';
  authenticatorAttachment?: 'platform' | 'cross-platform';
}

export interface WebAuthnPlugin {
  /**
   * Check if WebAuthn is available on this device
   */
  isAvailable(): Promise<{ available: boolean }>;

  /**
   * Start registration (credential creation) flow
   */
  startRegistration(
    options: StartRegistrationOptions,
  ): Promise<RegistrationCredential>;

  /**
   * Start authentication flow
   */
  startAuthentication(
    options: StartAuthenticationOptions,
  ): Promise<AuthenticationCredential>;
}
