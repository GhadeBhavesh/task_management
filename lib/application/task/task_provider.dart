import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/task/task.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          state =
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.data(), doc.id))
                  .toList();
        });
  }

  Future<void> addTask(
    String title,
    String description,
    DateTime dueDate,
    TaskPriority priority,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final task = Task(
      id: '', // Firestore will generate the ID
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      userId: user.uid,
    );

    await _firestore.collection('tasks').doc().set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({
        'isCompleted': !task.isCompleted,
      });
    } catch (e) {
      print('Error toggling task completion: $e');
    }
    // await updateTask(task);
  }
}
