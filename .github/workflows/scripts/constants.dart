import 'dart:io';
const bool debugOutput = false;

const pathToScripts = '.github/workflows/scripts/';

//Scripts to be executed in order
const String extractVersionsScript = 'extract-versions.sh';
const String firestoreVersionJSONPath = './tmp/firestore_versions.json';

const String extractRawZipUrlsScript = 'extract-urls.sh';
const String firestoreRawZipUrlsJSONPath = './tmp/firestore_urls.json';

const String extractPrivacyManifestURLSScript =
    './extract-privacy-manifest-urls.sh';
const String privacyManifestUrlsJSONPath = './tmp/privacy_manifest_urls.json';

const String writeNewZipScript = 'create-zips.sh';

const String updateFileVariableValues = 'update-file-variables.sh';

const String commitAndPublishScript = 'commit-and-publish.sh';