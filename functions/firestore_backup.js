const { v1 } = require('@google-cloud/firestore');
const functions = require('firebase-functions');
const { format } = require('date-fns');

const client = new v1.FirestoreAdminClient();

exports.scheduledFirestoreBackup = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
  const databaseName = client.databasePath(projectId, '(default)');
  const bucket = 'gs://idea_board_firestore_backups';

  // Get the current date and time
  const now = new Date();
  const timestamp = format(now, 'yyyy-MM-dd_HH-mm-ss');

  // Set the output URI prefix to include the timestamp
  const outputUriPrefix = `${bucket}/backup_${timestamp}`;

  try {
    console.log(`Starting Firestore backup to ${outputUriPrefix}`);
    const [response] = await client.exportDocuments({
      name: databaseName,
      outputUriPrefix: outputUriPrefix,
      collectionIds: []  // Leave empty to export all collections
    });

    console.log(`Backup completed successfully: ${response.outputUriPrefix}`);
  } catch (err) {
    console.error('Error during Firestore backup:', err);
    throw new Error('Firestore backup failed');
  }
});
