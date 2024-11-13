import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  final CollectionReference todoRef =
      FirebaseFirestore.instance.collection('Product');

  Future<void> addTodo(
      {required String taskName, required String time}) {
    return todoRef.add({
      'task_name': taskName,
      'time': time,
    });
  }

  Stream<QuerySnapshot> getTodos() {
    return todoRef.snapshots();
  }

  Future<void> updateTodo(
      {required String taskId, required Map<String, dynamic> updatedData}) {
    return todoRef.doc(taskId).update(updatedData);
  }

  Future<void> deleteTodo({required String taskId}) {
    return todoRef.doc(taskId).delete();
  }
}
