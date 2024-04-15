const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { OpenAI } = require("openai");


const openAIApiKey = defineSecret("OPENAI_API_KEY");

exports.generateanswer = onRequest(
  { secrets: [openAIApiKey] },
  async (req, res) => {
    const openai = new OpenAI({ apiKey: openAIApiKey.value() });
    const completion = await openai.chat.completions.create({
      messages: [{ role: "system", content: "You are a helpful assistant." }],
      model: "gpt-4-turbo-2024-04-09",
    });
    res.status(200).send(completion.choices[0].message.content);
  }
)