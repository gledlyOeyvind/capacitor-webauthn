package eu.gledly.plugins.capacitor_webauthn;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.credentials.CreateCredentialResponse;
import androidx.credentials.CreatePublicKeyCredentialRequest;
import androidx.credentials.CreatePublicKeyCredentialResponse;
import androidx.credentials.Credential;
import androidx.credentials.CredentialManager;
import androidx.credentials.CredentialManagerCallback;
import androidx.credentials.GetCredentialRequest;
import androidx.credentials.GetCredentialResponse;
import androidx.credentials.GetPublicKeyCredentialOption;
import androidx.credentials.PasswordCredential;
import androidx.credentials.PublicKeyCredential;
import androidx.credentials.exceptions.CreateCredentialException;
import androidx.credentials.exceptions.GetCredentialException;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import org.json.JSONException;
import java.util.concurrent.Executor;

@CapacitorPlugin(name = "WebAuthn")
public class WebAuthnPlugin extends Plugin {
    private static final String TAG = "WebAuthnPlugin";
    private CredentialManager credentialManager;
    private Executor executor;

    @Override
    public void load() {
        super.load();
        // Initialize CredentialManager with your app's context
        credentialManager = CredentialManager.create(getContext());
        // Use main executor for callbacks
       if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
           executor = getContext().getMainExecutor();
       } else {
           executor = new Executor() {
               private final Handler handler = new Handler(Looper.getMainLooper());

               @Override
               public void execute(Runnable command) {
                   handler.post(command);
               }
           };
       }
        Log.d(TAG, "WebAuthn plugin loaded successfully");
    }

    @PluginMethod
    public void isAvailable(PluginCall call) {
        // WebAuthn is available on Android 9+ (API 28) with Google Play Services
        JSObject ret = new JSObject();
        ret.put("available", android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P);
        call.resolve(ret);
    }

    @PluginMethod
    public void startAuthentication(PluginCall call) {
        String requestJson = call.getData().toString();
        Log.d(TAG, "startAuthentication - Request: " + requestJson);

        try {
            // Create the PublicKeyCredential option
            GetPublicKeyCredentialOption getPublicKeyCredentialOption =
                new GetPublicKeyCredentialOption(requestJson);

            // Build the request
            GetCredentialRequest getCredRequest =
                new GetCredentialRequest.Builder()
                    .addCredentialOption(getPublicKeyCredentialOption)
                    .build();

            // Execute the credential request
            credentialManager.getCredentialAsync(
                getActivity(),
                getCredRequest,
                null, // CancellationSignal - null for now
                executor,
                new CredentialManagerCallback<GetCredentialResponse, GetCredentialException>() {
                    @Override
                    public void onResult(GetCredentialResponse result) {
                        handleGetCredentialResponse(call, result);
                    }

                    @Override
                    public void onError(GetCredentialException e) {
                        Log.e(TAG, "Authentication failed", e);
                        handleCredentialError(call, "Authentication", e);
                    }
                }
            );
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error in startAuthentication", e);
            call.reject("Authentication failed: " + e.getMessage());
        }
    }

    @PluginMethod
    public void startRegistration(PluginCall call) {
        String requestJson = call.getData().toString();

        // Debug logging to understand the data
        Log.d(TAG, "startRegistration - Raw data: " + requestJson);

        try {
            // Validate that we have proper JSON
            JSObject testParse = new JSObject(requestJson);
            Log.d(TAG, "JSON validation passed, creating credential request");

            // Log specific fields for debugging
            if (testParse.has("user")) {
                JSObject user = testParse.getJSObject("user");
                Log.d(TAG, "User name: " + user.getString("name"));
                Log.d(TAG, "User display name: " + user.getString("displayName"));
            }

            // Create the request using the JSON string directly
            CreatePublicKeyCredentialRequest createPublicKeyCredentialRequest =
                new CreatePublicKeyCredentialRequest(requestJson);

            Log.d(TAG, "CreatePublicKeyCredentialRequest created successfully");

            // Execute the credential creation
            credentialManager.createCredentialAsync(
                getActivity(),
                createPublicKeyCredentialRequest,
                null, // CancellationSignal - null for now
                executor,
                new CredentialManagerCallback<CreateCredentialResponse, CreateCredentialException>() {
                    @Override
                    public void onResult(CreateCredentialResponse result) {
                        Log.d(TAG, "Credential creation successful");
                        handleCreateCredentialResponse(call, result);
                    }

                    @Override
                    public void onError(CreateCredentialException e) {
                        Log.e(TAG, "Credential creation failed", e);
                        handleCredentialError(call, "Registration", e);
                    }
                }
            );
        } catch (JSONException e) {
            Log.e(TAG, "Invalid JSON in request", e);
            call.reject("Invalid request format: " + e.getMessage());
        } catch (Exception e) {
            Log.e(TAG, "Unexpected error in startRegistration", e);
            call.reject("Registration failed: " + e.getMessage());
        }
    }

    private void handleGetCredentialResponse(PluginCall call, GetCredentialResponse response) {
        try {
            Credential credential = response.getCredential();

            if (credential instanceof PublicKeyCredential) {
                String responseJson = ((PublicKeyCredential) credential).getAuthenticationResponseJson();
                Log.d(TAG, "Authentication successful");
                JSObject ret = new JSObject(responseJson);
                call.resolve(ret);
            } else if (credential instanceof PasswordCredential) {
                Log.e(TAG, "Unexpected: PasswordCredential returned for passkey request");
                call.reject("Unexpected credential type: password credential");
            } else {
                Log.e(TAG, "Unknown credential type returned");
                call.reject("Unknown credential type");
            }
        } catch (JSONException e) {
            Log.e(TAG, "Failed to parse authentication response", e);
            call.reject("Failed to parse authentication response");
        }
    }

    private void handleCreateCredentialResponse(PluginCall call, CreateCredentialResponse response) {
        try {
            String responseJson = null;

            // First try the modern approach
            if (response instanceof CreatePublicKeyCredentialResponse) {
                responseJson = ((CreatePublicKeyCredentialResponse) response).getRegistrationResponseJson();
                Log.d(TAG, "Got response using CreatePublicKeyCredentialResponse method");
            }

            if (responseJson != null && !responseJson.isEmpty()) {
                Log.d(TAG, "Registration response: " + responseJson);
                JSObject ret = new JSObject(responseJson);
                call.resolve(ret);
            } else {
                Log.e(TAG, "No registration response JSON found in the result");
                call.reject("No registration response found");
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to handle registration response", e);
            call.reject("Failed to process registration response: " + e.getMessage());
        }
    }

    private void handleCredentialError(PluginCall call, String operation, Exception e) {
        String errorType = e.getClass().getSimpleName();
        String errorMessage = e.getMessage() != null ? e.getMessage() : "Unknown error";

        // Provide user-friendly messages for common errors
        if (errorMessage.contains("cancelled") || errorMessage.contains("Cancel")) {
            errorMessage = operation + " was cancelled by the user";
        } else if (errorMessage.contains("No create options")) {
            errorMessage = "No passkey providers available. Please ensure you have a compatible authenticator.";
        }

        Log.e(TAG, errorType + ": " + errorMessage);
        call.reject(errorMessage);
    }
}
