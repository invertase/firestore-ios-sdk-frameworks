import 'dart:convert';
import 'dart:io';
import 'constants.dart';
import 'package:path/path.dart' as p;

class FirestoreVersions {
  FirestoreVersions({
    required this.firebase_firestore_version,
    required this.firebase_firestore_grpc_version,
    required this.firebase_firestore_leveldb_version,
    required this.firebase_firestore_nanopb_version_min,
    required this.firebase_firestore_nanopb_version_max,
    required this.firebase_firestore_abseil_version,
  });

  final String firebase_firestore_version;
  final String firebase_firestore_grpc_version;
  final String firebase_firestore_leveldb_version;
  final String firebase_firestore_nanopb_version_min;
  final String firebase_firestore_nanopb_version_max;
  final String firebase_firestore_abseil_version;
}

class RawZipUrls {
  RawZipUrls({
    required this.firebase_firestore_abseil_url,
    required this.firebase_firestore_grpc_version_url,
    required this.firebase_firestore_grpc_boringssl_url,
    required this.firebase_firestore_grpc_ccp_version_url,
    required this.firebase_firestore_internal_url,
  });

  final String firebase_firestore_abseil_url;
  final String firebase_firestore_grpc_version_url;
  final String firebase_firestore_grpc_boringssl_url;
  final String firebase_firestore_grpc_ccp_version_url;
  final String firebase_firestore_internal_url;
}

class PrivacyManifestUrls {
  PrivacyManifestUrls({
    required this.grpcpp_privacy_resource_url,
    required this.open_ssl_privacy_resource_url,
    required this.grpc_privacy_resource_url,
    required this.abseil_privacy_resource_url,
    required this.firestore_internal_privacy_resource_url,
  });

  final String grpcpp_privacy_resource_url;
  final String open_ssl_privacy_resource_url;
  final String grpc_privacy_resource_url;
  final String abseil_privacy_resource_url;
  final String firestore_internal_privacy_resource_url;
}

Future<FirestoreVersions> getVersions(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found: $filePath');
  }

  final fileContent = await file.readAsString();
  await file.delete();

  final jsonData = jsonDecode(fileContent);

  return FirestoreVersions(
    firebase_firestore_version: jsonData['firebase_firestore_version'],
    firebase_firestore_grpc_version:
        jsonData['firebase_firestore_grpc_version'],
    firebase_firestore_leveldb_version:
        jsonData['firebase_firestore_leveldb_version'],
    firebase_firestore_nanopb_version_min:
        jsonData['firebase_firestore_nanopb_version_min'],
    firebase_firestore_nanopb_version_max:
        jsonData['firebase_firestore_nanopb_version_max'],
    firebase_firestore_abseil_version:
        jsonData['firebase_firestore_abseil_version'],
  );
}

Future<RawZipUrls> getRawUrls(String filePath, String firestoreVersion) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found: $filePath');
  }

  final fileContent = await file.readAsString();
  await file.delete();

  final jsonData = jsonDecode(fileContent);

  return RawZipUrls(
    firebase_firestore_abseil_url: jsonData['firebase_firestore_abseil_url'],
    firebase_firestore_grpc_version_url:
        jsonData['firebase_firestore_grpc_version_url'],
    firebase_firestore_grpc_boringssl_url:
        jsonData['firebase_firestore_grpc_boringssl_url'],
    firebase_firestore_grpc_ccp_version_url:
        jsonData['firebase_firestore_grpc_ccp_version_url'],
    firebase_firestore_internal_url:
        'https://dl.google.com/firebase/ios/bin/firestore/$firestoreVersion/FirebaseFirestoreInternal.zip',
  );
}

Future<PrivacyManifestUrls> getPrivacyManifestUrls(
    String filePath, String firestoreVersion) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found: $filePath');
  }

  final fileContent = await file.readAsString();
  await file.delete();

  final jsonData = jsonDecode(fileContent);

  return PrivacyManifestUrls(
    grpcpp_privacy_resource_url: jsonData['grpcpp_privacy_resource_url'],
    open_ssl_privacy_resource_url: jsonData['open_ssl_privacy_resource_url'],
    grpc_privacy_resource_url: jsonData['grpc_privacy_resource_url'],
    abseil_privacy_resource_url: jsonData['abseil_privacy_resource_url'],
    firestore_internal_privacy_resource_url:
        'https://raw.githubusercontent.com/firebase/firebase-ios-sdk/$firestoreVersion/Firestore/Source/Resources/PrivacyInfo.xcprivacy',
  );
}

Future<void> createZips(
    RawZipUrls rawZipUrls, PrivacyManifestUrls privacyManifestUrls) async {
  final urls = [
    rawZipUrls.firebase_firestore_abseil_url,
    rawZipUrls.firebase_firestore_grpc_version_url,
    rawZipUrls.firebase_firestore_grpc_boringssl_url,
    rawZipUrls.firebase_firestore_grpc_ccp_version_url,
    rawZipUrls.firebase_firestore_internal_url,
  ];

  for (final url in urls) {
    if (url == rawZipUrls.firebase_firestore_abseil_url) {
      await createZip(
        url,
        privacyManifestUrls.abseil_privacy_resource_url,
        './Archives/abseil.zip',
      );
    }
    if (url == rawZipUrls.firebase_firestore_grpc_version_url) {
      await createZip(
        url,
        privacyManifestUrls.grpc_privacy_resource_url,
        './Archives/grpc.zip',
      );
    }
    if (url == rawZipUrls.firebase_firestore_grpc_boringssl_url) {
      await createZip(
        url,
        privacyManifestUrls.open_ssl_privacy_resource_url,
        './Archives/openssl.zip',
      );
    }
    if (url == rawZipUrls.firebase_firestore_grpc_ccp_version_url) {
      await createZip(
        url,
        privacyManifestUrls.grpcpp_privacy_resource_url,
        './Archives/grpcpp.zip',
      );
    }
    if (url == rawZipUrls.firebase_firestore_internal_url) {
      await createZip(
        url,
        privacyManifestUrls.firestore_internal_privacy_resource_url,
        './Archives/firestore_internal.zip',
      );
    }
  }
}

Future<void> createZip(
  String zipUrl,
  String privacy_manifest_url,
  String zipPath,
) async {
  final result = await Process.run(
    'bash',
    [
      p.join(
        pathToScripts,
        writeNewZipScript,
      ),
      zipUrl,
      privacy_manifest_url,
      zipPath,
    ],
  );

  // if (debugOutput) {
  //   print(result.stdout);
  // }
  print(result.stdout);

  if (result.exitCode != 0) {
    throw Exception('Creating zip failed: ${result.stderr}');
  }
}

String createURLToZip(String zipName, String firebaseSdkVersion) {
  return 'https://github.com/invertase/firestore-ios-sdk-frameworks/raw/$firebaseSdkVersion/Archives/$zipName.zip';
}
