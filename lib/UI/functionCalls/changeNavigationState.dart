import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void changeNavigationStateToTrue(
    {@required gameID, @required field, playerField}) async {
  if (field == 'isGameStarted') {
    Firestore.instance.collection('rooms').document(gameID).updateData(
      {
        field: true,
      },
    );
  } else {
    Firestore.instance
        .collection('rooms')
        .document(gameID)
        .collection('users')
        .snapshots()
        .listen(
      (event) {
        if (event.documents
            .every((element) => element.data[playerField] == true)) {
          Firestore.instance.collection('rooms').document(gameID).updateData(
            {
              field: true,
            },
          );
        }
      },
    );
  }
}

void changeNavigationStateToFalse({@required gameID, @required field}) async {
  Firestore.instance.collection('rooms').document(gameID).updateData(
    {field: false},
  );
}
