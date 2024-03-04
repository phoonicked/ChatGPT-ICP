// Import required libraries
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";

// Import custom types from Types.mo
import Types "Types";

actor {

  // Function to transform the response
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        {
          name = "Content-Security-Policy";
          value = "default-src 'self'";
        },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        {
          name = "Strict-Transport-Security";
          value = "max-age=63072000";
        },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  // PUBLIC METHOD
  // This method sends a POST request to the ChatGPT API
  public func send_chat_gpt_request(inputText : Text) : async Text {
    // Declare the management canister
    let ic : Types.IC = actor ("aaaaa-aa");

    // Setup arguments for HTTP POST request
    let host : Text = "api.openai.com";
    let url = "https://api.openai.com/v1/chat/completions";
    let apiKey = "nuh uh";
    let idempotencyKey : Text = generateUUID();
    let requestHeaders = [
      { name = "Host"; value = host # ":443" },
      { name = "User-Agent"; value = "chatGPT_request" },
      { name = "Content-Type"; value = "application/json" },
      { name = "Authorization"; value = "Bearer " # apiKey },
      { name = "Idempotency-Key"; value = idempotencyKey },
    ];

    // Construct the request body manually
    let requestBody : Text = "{ \"model\": \"gpt-3.5-turbo\", \"messages\": [ { \"role\": \"system\", \"content\": \"You are a helpful assistant.\" }, { \"role\": \"user\", \"content\": \"" # inputText # "\" } ] }";

    let requestBodyAsBlob : Blob = Text.encodeUtf8(requestBody);
    let requestBodyAsNat8 : [Nat8] = Blob.toArray(requestBodyAsBlob);

    let transformContext : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let httpRequest : Types.HttpRequestArgs = {
      url = url;
      max_response_bytes = null;
      headers = requestHeaders;
      body = ?requestBodyAsNat8;
      method = #post;
      transform = ?transformContext;
    };

    // Add cycles to pay for HTTP request
    Cycles.add(21_850_258_000);

    // Make HTTPS request and wait for response
    let httpResponse : Types.HttpResponsePayload = await ic.http_request(httpRequest);

    // Decode the response body
    let responseBody : Blob = Blob.fromArray(httpResponse.body);
    let decodedText : Text = switch (Text.decodeUtf8(responseBody)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    // Return the decoded response
    decodedText;
  };

  // PRIVATE HELPER FUNCTION
  // Helper method that generates a Universally Unique Identifier
  func generateUUID() : Text {
    "UUID-123456789";
  };
};
