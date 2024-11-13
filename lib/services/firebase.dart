import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final CollectionReference orderRef = FirebaseFirestore.instance.collection('Order Table');
// Add Order Function

Future addOrder(int ordersID, String customerName, double totalCost, int quantity) async {
  return await orderRef.add({
    'ordersID' : ordersID,
    'customerName': customerName,
    'totalCost' : totalCost,
    'quantity' : quantity,
    'orderDate' : FieldValue.serverTimestamp()
  });
}
// Get Function
Stream<QuerySnapshot> getOrders(){
  return orderRef.snapshots();
}
}

  // Future<void> updateTodo(
  //     {required String taskId, required Map<String, dynamic> updatedData}) {
  //   return todoRef.doc(taskId).update(updatedData);
  // }

  // Future<void> deleteTodo({required String taskId}) {
  //   return todoRef.doc(taskId).delete();
  // }
