import { registerPlugin } from '@capacitor/core';

import type { WebAuthnPluginPlugin } from './definitions';

const WebAuthnPlugin = registerPlugin<WebAuthnPluginPlugin>('WebAuthnPlugin', {
  web: () => import('./web').then((m) => new m.WebAuthnPluginWeb()),
});

export * from './definitions';
export { WebAuthnPlugin };
