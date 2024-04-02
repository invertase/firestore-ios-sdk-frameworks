import 'dart:io';
import 'utils.dart';
import 'constants.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  // Step 1: Extract versions
  final versionResults = await Process.run(
    'bash',
    [
      p.join(
        pathToScripts,
        extractVersionsScript,
      ),
      firestoreVersionJSONPath
    ],
  );

  if (debugOutput) {
    print(versionResults.stdout);
  }

  if (versionResults.exitCode != 0) {
    throw Exception('Getting versions failed: ${versionResults.stderr}');
  }

  final versions = await getVersions(firestoreVersionJSONPath);

  // Step 2: Extract raw zip urls for creating our own with privacy manifests
  final rawUrlResults = await Process.run(
    'bash',
    [
      p.join(
        pathToScripts,
        extractRawZipUrlsScript,
      ),
      firestoreRawZipUrlsJSONPath,
      versions.firebase_firestore_grpc_version,
      versions.firebase_firestore_abseil_version,
    ],
  );

  if (debugOutput) {
    print(rawUrlResults.stdout);
  }

  if (rawUrlResults.exitCode != 0) {
    throw Exception('Getting raw urls failed: ${rawUrlResults.stderr}');
  }

  final rawUrls = await getRawUrls(
    firestoreRawZipUrlsJSONPath,
    versions.firebase_firestore_version,
  );

  // Step 3: Extract privacy manifest urls
  final privacyManifestUrlsResults = await Process.run(
    'bash',
    [
      p.join(
        pathToScripts,
        extractPrivacyManifestURLSScript,
      ),
      privacyManifestUrlsJSONPath,
      versions.firebase_firestore_abseil_version,
      versions.firebase_firestore_grpc_version,
    ],
  );

  if (debugOutput) {
    print(privacyManifestUrlsResults.stdout);
  }

  if (privacyManifestUrlsResults.exitCode != 0) {
    throw Exception(
        'Getting privacy manifest urls failed: ${privacyManifestUrlsResults.stderr}');
  }

  final privacyManifestUrls = await getPrivacyManifestUrls(
    privacyManifestUrlsJSONPath,
    versions.firebase_firestore_version,
  );
  // Step 4: Create custom zips
  await createZips(rawUrls, privacyManifestUrls);

// Step 5: Update the variables at the top of each podspec file
  final updateFileVariableValuesResults = await Process.run(
    'bash',
    [
      p.join(
        pathToScripts,
        updateFileVariableValues,
      ),
      versions.firebase_firestore_version,
      versions.firebase_firestore_abseil_version,
      versions.firebase_firestore_grpc_version,
      versions.firebase_firestore_leveldb_version,
      versions.firebase_firestore_nanopb_version_min,
      versions.firebase_firestore_nanopb_version_max,
      createURLToZip('grpc'),
      createURLToZip('abseil'),
      createURLToZip('firestore_internal'),
      createURLToZip('openssl'),
      createURLToZip('grpcpp'),
    ],
  );

  if (debugOutput) {
    print(updateFileVariableValuesResults.stdout);
  }

  if (updateFileVariableValuesResults.exitCode != 0) {
    throw Exception(
        'Updating file variable values failed: ${updateFileVariableValuesResults.stderr}');
  }

// Step 6: Commit and publish to cocoapods
  final commitAndPublishResults = await Process.run(
    'bash',
    [
      p.join(pathToScripts, commitAndPublishScript,),
      versions.firebase_firestore_version,
      versions.firebase_firestore_grpc_version,
      versions.firebase_firestore_abseil_version,
    ],
  );

  if (debugOutput) {
    print(commitAndPublishResults.stdout);
  }

  if (commitAndPublishResults.exitCode != 0) {
    throw Exception(
        'Committing and publishing failed: ${commitAndPublishResults.stderr}');
  }
}
