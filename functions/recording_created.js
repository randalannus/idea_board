const { onObjectFinalized } = require("firebase-functions/v2/storage");
const { getStorage } = require("firebase-admin/storage");
const { getFirestore } = require('firebase-admin/firestore');
const { defineSecret } = require("firebase-functions/params");
const { OpenAI } = require("openai");


const db = getFirestore();
const openAIApiKey = defineSecret("OPENAI_API_KEY");

module.exports.recordingCreated = onObjectFinalized(
  {
    bucket: "mind-boxes.appspot.com",
    region: "europe-west3",
    memory: "1GiB",
    secrets: [openAIApiKey],
  },
  async (event) => {
    path = event.data.name;
    const regex = /^users\/([a-zA-Z0-9]+)\/ideas\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\/voiceRecordings\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\.mp4$/;
    const match = path.match(regex);

    if (!match) {
      return;
    }
    const userId = match[1];
    const ideaId = match[2];

    transcription = await transcribeAudio(event.data.bucket, event.data.name);
    await appendTextToIdea(transcription, userId, ideaId);
  }
);


async function transcribeAudio(bucketName, fileName) {
  const bucket = getStorage().bucket(bucketName);
  const file = bucket.file(fileName);
  const downloadResponse = await file.download();
  const openaiFile = await OpenAI.toFile(downloadResponse[0], ".mp4");
  
  const openai = new OpenAI({ apiKey: openAIApiKey.value() });
  const transcription = await openai.audio.transcriptions.create({
      file: openaiFile,
      model: "whisper-1",
  });

  return transcription.text;
};

async function appendTextToIdea(text, userId, ideaId) {
  const ref = db.doc(`users/${userId}/ideas/${ideaId}`);
  const snapshot = await ref.get();
  const idea = snapshot.data();

  await ref.update({
    text: idea.text == null || idea.text == "" ? text : idea.text + "\n\n" + text,
  });
}