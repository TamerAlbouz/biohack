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

  final mockService = FirestoreMockDataService();

  // Create mock users
  // Create chat room between first two users
  // final chatRoomId = await mockService.createMockChatRoom(
  //     "OIBkRV4PRMYcZTodlm5HHCAvHKJ3", "j6OGfC4BhRguGUSNycrCHy71GfJ3");

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
}
