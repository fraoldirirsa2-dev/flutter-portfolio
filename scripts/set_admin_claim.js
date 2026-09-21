/**
 * One-time/local helper for admin authorization.
 *
 * Required PowerShell setup:
 *   $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\path\\service-account.json"
 *
 * Run:
 *   node scripts/set_admin_claim.js YOUR_FIREBASE_AUTH_UID
 *
 * Uses the current modular Firebase Admin SDK API.
 */

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'website-portfolio-65d8a';

async function main() {
  const uid = process.argv[2]?.trim();

  if (!uid) {
    throw new Error(
      'Usage: node scripts/set_admin_claim.js FIREBASE_AUTH_UID',
    );
  }

  const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!credentialsPath) {
    throw new Error(
      'GOOGLE_APPLICATION_CREDENTIALS is not set. Set it to your Firebase service-account JSON file.',
    );
  }

  initializeApp({
    credential: applicationDefault(),
    projectId: PROJECT_ID,
  });

  const auth = getAuth();
  const user = await auth.getUser(uid);

  await auth.setCustomUserClaims(uid, {
    ...(user.customClaims || {}),
    admin: true,
  });

  console.log('Admin claim set successfully.');
  console.log(`Project: ${PROJECT_ID}`);
  console.log(`UID: ${uid}`);
  console.log(`Email: ${user.email || '(no email)'}`);
  console.log('Sign out and sign in again in the Flutter app to refresh the ID token.');
}

main().catch((error) => {
  console.error('\nAdmin claim update failed.');
  if (error?.code) console.error(`Code: ${error.code}`);
  console.error(error?.message || error);
  process.exit(1);
});
