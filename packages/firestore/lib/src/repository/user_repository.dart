import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore/src/extensions/object.dart';
import 'package:models/models.dart';
import 'package:p_logger/p_logger.dart';

/// Repository which manages user collection.
class UserRepository {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<List<User>> getUsers() {
    try {
      return _userCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return User.fromMap(doc.data().toMap());
        }).toList();
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      return const Stream.empty();
    } catch (e) {
      logger.e(e);
      return const Stream.empty();
    }
  }

  Stream<User> getUser(String userId) {
    try {
      return _userCollection.doc(userId).snapshots().map((doc) {
        return User.fromMap(doc.data().toMap());
      });
    } on FirebaseException catch (e) {
      logger.e(e.message);
      return const Stream.empty();
    } catch (e) {
      logger.e(e);
      return const Stream.empty();
    }
  }

  Future<void> addTodo(User user) {
    try {
      return _userCollection.add(user.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      return Future.value();
    } catch (e) {
      logger.e(e);
      return Future.value();
    }
  }

  Future<void> updateTodo(User user) {
    try {
      return _userCollection.doc(user.uid).update(user.toMap());
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      return Future.value();
    } catch (e) {
      logger.e(e);
      return Future.value();
    }
  }

  Future<void> deleteTodo(String userId) {
    try {
      return _userCollection.doc(userId).delete();
    } on FirebaseException catch (e) {
      logger.e(e.message);
      // return empty future
      return Future.value();
    } catch (e) {
      logger.e(e);
      return Future.value();
    }
  }
}
