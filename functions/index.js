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
      referencedIdeaIds: []
    });

    // promt ChatGPT to respond and get the streamed completion
    updateStream = getMessageUpdateStream(params.userId, params.chatId);
    for await (const update of updateStream) {
      responseDocRef.update(update);
    }
});

const systemPrompt = `You are a helpful assistant.
Be concise and straight to the point in your answers.
You have access to all ideas (think of them as notes) written by the user.
If you do reference an idea, then explain why you see the idea being relevant in this case.
If the user asks you to list ideas, then list at least 3 or more.`;

async function* getMessageUpdateStream(userId, chatId) {
  // Give all ideas as input to the chatbot
  const ideas = await _getIdeas(userId);
  // Get the previous chat history
  const messages = await _getMessages(userId, chatId);
  
  const response = {
    text: "",
    referencedIdeaIds: [],
    writing: true,
  };
  completion = await _getGptAnswerStream(ideas, messages, true);

  for await (const chunk of completion) {
    let newText = chunk.choices[0].delta.content;
    if (typeof newText === "undefined") {
      continue;
    }
    response.text += newText;
    yield response;
  }
  
  const references = await getReferences(response.text, ideas);
  response.referencedIdeaIds = references;
  // Let the user know that the chatbot is finished with this message
  response.writing = false;
  yield response;
}

async function _getGptAnswerStream(ideas, messages, stream=true) {
  const parsedMessages = messages.map(msg => {return {
    "role": msg.by == "user" ? "user" : "assistant",
    "content": msg.text,
  }})

  const openai = new OpenAI({ apiKey: openAIApiKey.value() });
  const completion = await openai.chat.completions.create({
    model: "gpt-4-turbo-2024-04-09",
    messages: [
      {"role": "system", "content": systemPrompt},
      {"role": "system", "content": _ideasPrompt(ideas)},
      ...parsedMessages
    ],
    stream: stream,
  });
  return completion
}

async function _getIdeas(userId) {
  const snapshot = await db.collection(`users/${userId}/ideas`).get();
  var ideas = [];
  snapshot.forEach(doc => {
    ideas.push(doc.data());
  })
  return ideas;
}

async function _getMessages(userId, chatId) {
  const snapshot = await db.collection(`users/${userId}/chats/${chatId}/messages`).orderBy("createdAt").get();
  const messages = [];
  snapshot.forEach(doc => {messages.push(doc.data());});
  // Remove the empty bot response message
  messages.pop()
  return messages;
}

function _generateAliasMap(ideas) {
  var aliasMap = {};
  ideas.forEach(idea => {
    const alias = _generateRandomAlias(5);
    aliasMap[alias] = idea.id;
    aliasMap[idea.id] = alias;
  })
  return aliasMap;
}

function _generateRandomAlias(length) {
  const characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * characters.length);
      result += characters[randomIndex];
  }
  return result;
}

function _ideasPrompt(ideas, aliasMap={}) {
  var ideasPrompt = "";
  ideas.forEach(idea => {
    text = idea.text
    if (typeof text === "undefined") {
      return;
    }

    const alias = aliasMap[idea.id];
    var aliasPrompt = "";
    if (typeof alias !== "undefined") {
      aliasPrompt = `(ID:${alias})`;
    }

    ideasPrompt += `--- Idea ${aliasPrompt} ---\n`;
    ideasPrompt += text;
    ideasPrompt += "\n\n";
  })
  return ideasPrompt;
}

async function getReferences(responseText, ideas) {
  const aliasMap = _generateAliasMap(ideas);

  const openai = new OpenAI({ apiKey: openAIApiKey.value() });
  const userPrompt = `You have access to all ideas (think of them as notes) written by the user.
  Which of my ideas did you explicitly mention in your last response?
  Please answer with only a json array of the ids, for example ["ABC12", "De23L"].
  If you didn't mention any ideas, then answer with only an empty array [].`
  const completion = await openai.chat.completions.create({
    model: "gpt-3.5-turbo-0125",
    messages: [
      {"role": "system", "content": _ideasPrompt(ideas, aliasMap)},
      {"role": "assistant", "content": responseText},
      {"role": "user", "content": userPrompt},
    ],
    stream: false,
  });

  const rawResponse = completion.choices[0].message.content;
  const jsonPart = rawResponse.substring(rawResponse.indexOf('['), rawResponse.lastIndexOf(']') + 1);
  // Replacing single quotes to double quotes for valid JSON format
  const jsonArray = JSON.parse(jsonPart.replace(/'/g, '"'));
  return jsonArray.map(alias => {return aliasMap[alias];});
}