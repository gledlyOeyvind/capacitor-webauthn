import { WebPlugin } from '@capacitor/core';

import type { WebAuthnPluginPlugin } from './definitions';

export class WebAuthnPluginWeb extends WebPlugin implements WebAuthnPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
