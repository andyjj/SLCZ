// Grants (or revokes) the "admin" custom claim on one or more Firebase Auth
// accounts, so they can access the app's admin sign-submission panel.
//
// Run locally — never deploy this or the service account key it needs.
//
// Setup (one-time):
//   1. npm install firebase-admin   (from this tool/admin/ folder)
//   2. Download a service account key: Firebase console -> Project settings
//      -> Service accounts -> Generate new private key. Save it as
//      tool/admin/serviceAccountKey.json (already gitignored - never commit it,
//      it grants full admin access to the whole Firebase project).
//
// Usage:
//   node grant_admin.js andyjj@hotmail.com ellenajones@hotmail.com ...
//   node grant_admin.js --revoke someone@example.com
//
// Each email must already be a registered user in the app (sign up via
// "Go ad-free - sign up" first) - this looks up an existing account, it
// doesn't create one.

const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require(path.join(__dirname, 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function main() {
  const args = process.argv.slice(2);
  const revoke = args.includes('--revoke');
  const emails = args.filter((a) => a !== '--revoke');

  if (emails.length === 0) {
    console.error('Usage: node grant_admin.js <email> [<email> ...]');
    console.error('       node grant_admin.js --revoke <email> [<email> ...]');
    process.exit(1);
  }

  for (const email of emails) {
    try {
      const user = await admin.auth().getUserByEmail(email);
      await admin.auth().setCustomUserClaims(user.uid, { admin: !revoke });
      console.log(`${revoke ? 'Revoked' : 'Granted'} admin for ${email} (uid: ${user.uid})`);
    } catch (err) {
      console.error(`Failed for ${email}: ${err.message}`);
    }
  }
}

main().then(() => process.exit(0));
