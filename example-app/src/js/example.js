import { WebAuthnPlugin } from 'capacitor-webauthn';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    WebAuthnPlugin.echo({ value: inputValue })
}
