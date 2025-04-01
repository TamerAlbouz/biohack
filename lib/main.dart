import 'package:backend/backend.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtalk/app/screens/route_auth.dart';
import 'package:medtalk/bloc_observer.dart';
import 'package:medtalk/styles/styles/system.dart';
import 'package:p_logger/p_logger.dart';
import 'package:uuid/uuid.dart';

void main() async {
  // log time as well
  final stopwatch = Stopwatch();
  stopwatch.start();
  logger.i('Starting application');

  logger.i('Initializing Firebase');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  logger.i('Firebase initialized');

  logger.i('Enabling Firestore persistence (cache)');
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  logger.i('Firestore persistence (cache) enabled');

  logger.i('Assigning Bloc observer');
  Bloc.observer = CustomBlocObserver();
  logger.i('Bloc observer assigned');

  logger.i('Setting system chrome');
  SystemChrome.setSystemUIOverlayStyle(kStatusBarDark);
  logger.i('System chrome set');

  logger.i('Configuring dependencies');
  await configureDependencies();
  logger.i('Dependencies configured');

  // only portrait mode
  logger.i('Setting preferred orientations');
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  logger.i('Preferred orientations set');

  logger.i('Initializing authentication repository');
  final IAuthenticationRepository authenticationRepository =
      getIt<IAuthenticationRepository>();
  await authenticationRepository.user.first;
  // check if role is already chosen
  logger.i('Authentication repository initialized');

  stopwatch.stop();
  logger.i('Running application took ${stopwatch.elapsedMilliseconds}ms');

  // final mockService = FirestoreMockDataService();

  runApp(App(authenticationRepository: authenticationRepository));
}

class FirestoreMockDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a mock chat room between two users
  Future<String> createMockChatRoom(String user1Id, String user2Id) async {
    // Sort IDs to ensure consistent chat room ID
    final sortedIds = [user1Id, user2Id]..sort();
    final chatRoomId = sortedIds.join('_');

    final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

    await chatRoomRef.set({
      'user1Id': sortedIds[0],
      'user2Id': sortedIds[1],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Add some mock messages
    final messagesRef = chatRoomRef.collection('messages');

    final mockMessages = [
      ChatMessage(
        id: const Uuid().v4(),
        senderId: user1Id,
        content: 'Hello, this is a test message!',
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        id: const Uuid().v4(),
        senderId: user2Id,
        content: 'Hi there, nice to meet you!',
        timestamp: DateTime.now().add(const Duration(minutes: 5)),
      )
    ];

    // Batch write messages
    final batch = _firestore.batch();
    for (var message in mockMessages) {
      final msgRef = messagesRef.doc(message.id);
      batch.set(msgRef, message.toMap());
    }

    await batch.commit();

    return chatRoomId;
  }

  Future<List<String>> batchInsertDoctors(
      List<Map<String, dynamic>> doctorDataList) async {
    final List<String> insertedIds = [];
    final batch = FirebaseFirestore.instance.batch();
    final doctorsCollection = FirebaseFirestore.instance.collection('doctors');

    try {
      // Process in chunks of 500 (Firestore batch limit)
      for (var i = 0; i < doctorDataList.length; i += 500) {
        final chunk = doctorDataList.skip(i).take(500).toList();

        // Create a new batch for each chunk
        final currentBatch = FirebaseFirestore.instance.batch();

        for (var doctorData in chunk) {
          // Convert DateTime fields to Timestamps
          final processedData = {
            ...doctorData,
            'createdAt': doctorData['createdAt'] is DateTime
                ? Timestamp.fromDate(doctorData['createdAt'])
                : doctorData['createdAt'],
            'updatedAt': doctorData['updatedAt'] is DateTime
                ? Timestamp.fromDate(doctorData['updatedAt'])
                : doctorData['updatedAt'],
          };

          // Remove null values
          processedData.removeWhere((key, value) => value == null);

          // Create document reference with auto-generated ID
          final docRef = doctorsCollection.doc();
          insertedIds.add(docRef.id);

          // Add to batch
          currentBatch.set(docRef, processedData);
        }

        // Commit the current batch
        await currentBatch.commit();
      }

      return insertedIds;
    } catch (e) {
      throw Exception('Failed to batch insert doctors: ${e.toString()}');
    }
  }

// Example usage with 45 doctors:
  Future<void> insert45Doctors() async {
    final List<Map<String, dynamic>> doctors = List.generate(
      45,
      (index) => {
        'email': 'doctor$index@hospital.com',
        'uid': 'uid$index',
        'active': true,
        'sex': index % 2 == 0 ? 'M' : 'F',
        'name': 'Doctor Name $index',
        'state': 'NY',
        'licNum': 'MC${10000 + index}',
        'govIdUrl': 'https://storage.url/govid$index',
        'medicalLicenseUrl': 'https://storage.url/license$index',
        'role': 'Specialist',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'appointments': [],
        'busy': false,
        'tokens': 100,
        'paymentIds': [],
        'specialties': ['General Medicine'],
        'reviewIds': [],
        'availability': {
          'monday': ['9:00-17:00'],
          'tuesday': ['9:00-17:00'],
          'wednesday': ['9:00-17:00'],
          'thursday': ['9:00-17:00'],
          'friday': ['9:00-17:00']
        }
      },
    );

    try {
      final insertedIds = await batchInsertDoctors(doctors);
      print('Successfully inserted ${insertedIds.length} doctors');
      print('First few doctor IDs: ${insertedIds.take(5).join(", ")}');
    } catch (e) {
      print('Error inserting doctors: $e');
    }
  }
}
