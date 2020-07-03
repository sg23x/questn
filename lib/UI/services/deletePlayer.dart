import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void deletePlayer({
  @required id,
  @required gameID,
}) async {
  await Firestore.instance
      .collection('rooms')
      .document(gameID)
      .collection('users')
      .document(id)
      .delete();
}
