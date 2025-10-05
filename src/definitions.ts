export interface WebAuthnPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
