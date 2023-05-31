import 'package:auth/services/auth.dart';
import 'package:flutter/material.dart';

class AllUsers extends StatelessWidget {
  AllUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: FutureBuilder(
          future: FirebaseServices().getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              iconColor: Colors.blue,
                              tileColor: Colors.blue.withOpacity(0.3),
                              leading: const Icon(Icons.person),
                              title: Text(snapshot.data![index].name),
                              ),
                            ),
                          ],
                      );
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
