const https = require('https');
const { google } = require('googleapis');
const PROJECT_ID = process.env.PROJECT_ID;
const HOST = 'fcm.googleapis.com';
const PATH = `/v1/projects/${PROJECT_ID}/messages:send`;
const MESSAGING_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
const SCOPES = [MESSAGING_SCOPE];

function getAccessToken() {
  return new Promise((resolve, reject) => {
    const key = require('./serviceAccount.json');
    const jwtClient = new google.auth.JWT(
      key.client_email,
      null,
      key.private_key,
      SCOPES,
      null
    );
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens.access_token);
    });
  });
}

function sendFcmMessage(fcmMessage) {
    getAccessToken().then(accessToken => {
      const options = {
        hostname: HOST,
        path: PATH,
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        }
      };
  
      // Construct the FCM message payload
      const payload = {
        message: {
          token: fcmMessage.receiverToken,
          notification: {
            title: fcmMessage.title,
            body: fcmMessage.body
          }
        }
      };
  
      const request = https.request(options, resp => {
        resp.setEncoding('utf8');
        resp.on('data', data => {
          console.log('Message sent to Firebase for delivery, response:');
          console.log(data);
        });
      });
      request.on('error', err => {
        console.error('Unable to send message to Firebase');
        console.error(err);
      });
      request.write(JSON.stringify(payload));
      request.end();
    }).catch(err => {
      console.error('Error obtaining access token:', err);
    });
}
  

module.exports = {
  sendFcmMessage
};
