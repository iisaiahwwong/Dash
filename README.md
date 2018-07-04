# Dash - Collaboration and Productivity
Dash is a prototype application for iOS aimed to eliminate the manual process of notetaking by transcribing discussions through text-to-speech. At the same time, dash allows extraction of intents from each session allowing users to further organise their information.

The application uses cloud services such as Google’s Cloud [text-to-speech](https://cloud.google.com/text-to-speech/) and Google’s [DialogFlow](https://dialogflow.com/) for intent Recognition. You may want to obtain the api keys.

This project uses [Firebase](https://console.firebase.google.com) as it's Datastore

## Getting Started
- DO NOT RUN `pod install`.
- Change the Bundle Identifier to match your domain.
- Go to [Firebase](https://firebase.google.com) and create new project.
- Select "Add Firebase to your iOS app" option, type the bundle Identifier & click continue.
- Download "GoogleService-Info.plist" file and add to the project. Make sure file name is "GoogleService-Info.plist".
- Go to [Firebase Console](https://console.firebase.google.com), select your project, choose "Authentication" from left menu, select "SIGN-IN METHOD" and enable "Email/Password" option.
- Open the terminal,  run `sh ./INSTALL`.
  - Script resolves boring SSL module imports conflicts in generated files.

## GOOGLE API KEYS
Once you've obtained your API KEY, rename `Keys.example.plist` to `Keys.plist`.
Add your API KEY to `GOOGLE_CLOUD_DEV` row.

## DialogFlow 
You might need to create your own web server to process the intents from dialogflow.
The current URI used is based on my domain.

10 stars > Example source code for server.
