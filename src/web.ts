import { WebPlugin } from '@capacitor/core';

import type {
  WebAuthnPlugin,
  StartRegistrationOptions,
  RegistrationCredential,
  StartAuthenticationOptions,
  AuthenticationCredential,
} from './definitions';

export class WebAuthnWeb extends WebPlugin implements WebAuthnPlugin {
  async isAvailable(): Promise<{ available: boolean }> {
    return {
      available:
        window?.PublicKeyCredential !== undefined &&
        typeof window.PublicKeyCredential === 'function',
    };
  }

  async startRegistration(
    options: StartRegistrationOptions,
  ): Promise<RegistrationCredential> {
    if (!window.PublicKeyCredential) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    // Convert base64url strings to ArrayBuffers
    const challenge = this.base64URLToBuffer(options.challenge);
    const userId = this.base64URLToBuffer(options.user.id);

    // Build the credential creation options
    const publicKeyCredentialCreationOptions: PublicKeyCredentialCreationOptions =
      {
        challenge,
        rp: {
          id: options.rp.id,
          name: options.rp.name,
        },
        user: {
          id: userId,
          name: options.user.name,
          displayName: options.user.displayName,
        },
        pubKeyCredParams: options.pubKeyCredParams.map((param) => ({
          type: param.type,
          alg: param.alg,
        })),
        timeout: options.timeout,
        excludeCredentials: options.excludeCredentials?.map((cred) => ({
          type: cred.type,
          id: this.base64URLToBuffer(cred.id),
          transports: cred.transports,
        })),
        authenticatorSelection: options.authenticatorSelection,
        attestation: options.attestation || 'none',
      };

    try {
      const credential = (await navigator.credentials.create({
        publicKey: publicKeyCredentialCreationOptions,
      })) as PublicKeyCredential | null;

      if (!credential) {
        throw new Error('Failed to create credential');
      }

      const response =
        credential.response as AuthenticatorAttestationResponse;

      return {
        id: credential.id,
        rawId: this.bufferToBase64URL(new Uint8Array(credential.rawId)),
        response: {
          clientDataJSON: this.bufferToBase64URL(
            new Uint8Array(response.clientDataJSON),
          ),
          attestationObject: this.bufferToBase64URL(
            new Uint8Array(response.attestationObject),
          ),
        },
        type: 'public-key',
        authenticatorAttachment: (credential as any).authenticatorAttachment as
          | 'platform'
          | 'cross-platform'
          | undefined,
      };
    } catch (error) {
      throw new Error(`Registration failed: ${error}`);
    }
  }

  async startAuthentication(
    options: StartAuthenticationOptions,
  ): Promise<AuthenticationCredential> {
    if (!window.PublicKeyCredential) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    // Convert base64url strings to ArrayBuffers
    const challenge = this.base64URLToBuffer(options.challenge);

    // Build the credential request options
    const publicKeyCredentialRequestOptions: PublicKeyCredentialRequestOptions =
      {
        challenge,
        rpId: options.rpId,
        timeout: options.timeout,
        allowCredentials: options.allowCredentials?.map((cred) => ({
          type: cred.type,
          id: this.base64URLToBuffer(cred.id),
          transports: cred.transports,
        })),
        userVerification: options.userVerification || 'preferred',
      };

    try {
      const credential = (await navigator.credentials.get({
        publicKey: publicKeyCredentialRequestOptions,
      })) as PublicKeyCredential | null;

      if (!credential) {
        throw new Error('Failed to get credential');
      }

      const response = credential.response as AuthenticatorAssertionResponse;

      return {
        id: credential.id,
        rawId: this.bufferToBase64URL(new Uint8Array(credential.rawId)),
        response: {
          clientDataJSON: this.bufferToBase64URL(
            new Uint8Array(response.clientDataJSON),
          ),
          authenticatorData: this.bufferToBase64URL(
            new Uint8Array(response.authenticatorData),
          ),
          signature: this.bufferToBase64URL(new Uint8Array(response.signature)),
          userHandle: response.userHandle
            ? this.bufferToBase64URL(new Uint8Array(response.userHandle))
            : undefined,
        },
        type: 'public-key',
        authenticatorAttachment: (credential as any).authenticatorAttachment as
          | 'platform'
          | 'cross-platform'
          | undefined,
      };
    } catch (error) {
      throw new Error(`Authentication failed: ${error}`);
    }
  }

  // Helper methods for base64url encoding/decoding
  private base64URLToBuffer(base64URL: string): ArrayBuffer {
    const base64 = base64URL.replace(/-/g, '+').replace(/_/g, '/');
    const padLen = (4 - (base64.length % 4)) % 4;
    const padded = base64 + '='.repeat(padLen);
    const binary = atob(padded);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes.buffer;
  }

  private bufferToBase64URL(buffer: Uint8Array): string {
    const binary = String.fromCharCode(...buffer);
    const base64 = btoa(binary);
    return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  }
}
