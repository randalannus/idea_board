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
    
    // Create the response message in the chat with empty text
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

    // promt ChatGPT to respond and get the streamed completion
    completion = await getCompletionStream(userMessage, params.userId, params.chatId);
    
    // Update the message with every event
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

    // Let the user know that the chatbot is finished with this message
    responseDocRef.update({
      writing: false
    });
});

const systemPrompt = `You are a helpful assistant.
You have access to all ideas (think of them as notes) written by the user.
Make reference to these ideas if you see useful or if asked by the user.
If you do reference an idea, then explain why you see the idea being relevant in this case.
Be concise and straight to the point in your answers.
If the user asks you to list ideas, then list at least 3 or more if relevant.`;

async function getCompletionStream(userMessage, userId, chatId) {
  // Give all ideas as input to the chatbot
  const ideasSnap = await db.collection(`users/${userId}/ideas`).get();
  var ideasPrompt = "";
  ideasSnap.forEach(doc => {
    text = doc.data()["text"]
    if (typeof text === 'undefined') {
      return;
    }
    ideasPrompt += "--- Idea ---\n";
    ideasPrompt += text;
    ideasPrompt += "\n\n";
  });

  // Get the previous chat history
  const messagesSnap = await db.collection(`users/${userId}/chats/${chatId}/messages`).get();
  const parsedMessages = [];
  messagesSnap.forEach(doc => {
    data = doc.data()
    parsedMessages.push({
      "role": data["by"] == "user" ? "user" : "assistant",
      "content": data["text"]
    })
  });

  // Append the user message if it is not the last one for some reason
  if (parsedMessages.at(-1)["role"] != "user") {
    parsedMessages.push({
      "role": "user",
      "content": userMessage.text
    })
  }

  const openai = new OpenAI({ apiKey: openAIApiKey.value() });
  const completion = await openai.chat.completions.create({
    model: "gpt-4-turbo-2024-04-09",
    messages: [
      {"role": "system", "content": systemPrompt},
      {"role": "system", "content": ideasPrompt},
      ...parsedMessages
    ],
    stream: true,
  });
  return completion
}