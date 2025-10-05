package eu.gledly.plugins.capacitor_webauthn;

import com.getcapacitor.Logger;

public class WebAuthnPlugin {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
