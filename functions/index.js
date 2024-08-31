const { initializeApp } = require('firebase-admin/app');
initializeApp();

const botReply = require('./bot_reply');
const recordingCreated = require('./recording_created');
const firestoreBackup = require('./firestore_backup');

exports.botReply = botReply;
exports.recordingCreated = recordingCreated;
exports.scheduledFirestoreBackup = firestoreBackup.scheduledFirestoreBackup;
