const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require('firebase-functions/params');

const { GoogleGenerativeAI } = require("@google/generative-ai");

const googleAiApiKey = defineSecret("GOOGLE_AI_API_KEY");


exports.test = onRequest(
  { secrets: [googleAiApiKey] },
  (req, res) => {
    res.status(200).send(googleAiApiKey.value());
  }
)