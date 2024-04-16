const { 
  onDocumentCreated,
  Change,
  FirestoreEvent 
} = require("firebase-functions/v2/firestore");
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { defineSecret } = require("firebase-functions/params");
const { OpenAI } = require("openai");
const { v4: uuidv4 } = require('uuid');

initializeApp();
const db = getFirestore();

const openAIApiKey = defineSecret("OPENAI_API_KEY");

exports.botreply = onDocumentCreated(
  {
    document: "/users/{userId}/chats/{chatId}/messages/{messageId}",
    region: "europe-west3",
    secrets: [openAIApiKey],
  },
  async (event) => {
    const userMessage = event.data.data();
    if (userMessage.by != "user") {
      return;
    }
    
    responseId = uuidv4();
    const params = event.params;
    responseDocRef = db.doc(`users/${params.userId}/chats/${params.chatId}/messages/${responseId}`);
    responseDocRef.set({
      by: "bot",
      text: "",
      id: responseId,
      createdAt: FieldValue.serverTimestamp(),
      replyingTo: userMessage.id,
      writing: true,
    });

    const openai = new OpenAI({ apiKey: openAIApiKey.value() });
    const completion = await openai.chat.completions.create({
      model: "gpt-4-turbo-2024-04-09",
      messages: [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": userMessage.text}
      ],
      stream: true,
    });
    
    var responseText = ""
    for await (const chunk of completion) {
      let newText = chunk.choices[0].delta.content;
      if (typeof newText === 'undefined') {
        continue;
      }
      responseText += newText;
      responseDocRef.update({
        text: responseText
      });
    }

    responseDocRef.update({
      writing: false
    });
});