import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class LoggedInWidget extends StatefulWidget {
  const LoggedInWidget({Key? key}) : super(key: key);

  @override
  State<LoggedInWidget> createState() => _LoggedInWidgetState();
}

class _LoggedInWidgetState extends State<LoggedInWidget> {
  String _newBarcode = '';
  String _newBarcodeName = '';
  String _newReview = '';

  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('barcodes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int index) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Додати відгук про\n${snapshot.data!.docs[index].get('barcode')}\n${snapshot.data!.docs[index].get('name')}',
                              style: const TextStyle(fontSize: 20),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.cancel_outlined),
                            ),
                          ],
                        ),
                        content: TextField(
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Ваш відгук',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: ((String value) => _newReview = value),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              if (_newReview == '') {
                                return null;
                              } else {
                                FirebaseFirestore.instance
                                    .collection('reviews')
                                    .add({'review': _newReview});
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Додати'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Dismissible(
                  key: Key(
                    snapshot.data!.docs[index].id,
                  ),
                  onDismissed: (direction) {
                    FirebaseFirestore.instance
                        .collection('barcodes')
                        .doc(snapshot.data!.docs[index].id)
                        .delete();
                  },
                  child: Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Штрихкод:',
                            style: TextStyle(fontSize: 22),
                          ),
                          Text(
                            snapshot.data!.docs[index].get('barcode'),
                            style: const TextStyle(fontSize: 22),
                          ),
                          Text(
                            snapshot.data!.docs[index].get('name'),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _newBarcode = '';
          _newBarcodeName = '';
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Додати штрихкод',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Штрихкод'),
                      onChanged: ((String value) => _newBarcode = value),
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Назва товару'),
                      onChanged: ((String value) => _newBarcodeName = value),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_newBarcode == '' || _newBarcodeName == '') {
                        return null;
                      } else {
                        FirebaseFirestore.instance.collection('barcodes').add(
                            {'barcode': _newBarcode, 'name': _newBarcodeName});
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Додати'),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}