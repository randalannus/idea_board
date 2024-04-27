const { initializeApp } = require('firebase-admin/app');
initializeApp();

const botReply = require('./bot_reply');
const recordingCreated = require('./recording_created');

exports.botReply = botReply;
exports.recordingCreated = recordingCreated;
