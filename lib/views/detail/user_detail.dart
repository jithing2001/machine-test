import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';
import 'package:test/controllers/provider/user_details_provider.dart';
import 'package:test/services/db_services/hive_db.dart';
import 'package:test/services/location_service/location_service.dart';

class UserDetail extends StatelessWidget {
  UserDetail({super.key, required this.user, required this.location});

  final UserModel user;
  Position? location;
  double? lastDistance;
  bool isFirstFetch = true;

  @override
  Widget build(BuildContext context) {
    Provider.of<UserDataProvider>(context, listen: false).fetchTodos(user.id!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child:
            Consumer<UserDataProvider>(builder: (context, userDataProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildDetailRow(Icons.person, 'Name', user.name!),
                StreamBuilder(
                  stream: LocationService().calculateDistance(
                      double.parse(user.address!.geo!.lat!),
                      double.parse(user.address!.geo!.lng!)),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting &&
                        isFirstFetch) {
                      return _buildDetailRow(
                          Icons.social_distance, 'Distance', 'Fetching');
                    } else if (snap.hasError) {
                      return _buildDetailRow(
                          Icons.social_distance, 'Distance', 'Not Available');
                    } else if (snap.hasData) {
                      if (lastDistance != snap.data) {
                        lastDistance = snap.data;
                        isFirstFetch = false;
                      }
                      return _buildDetailRow(Icons.social_distance, 'Distance',
                          "${snap.data} Kms");
                    }
                    return _buildDetailRow(
                        Icons.social_distance, 'Distance', "$lastDistance Kms");
                  },
                ),
                _buildDetailRow(
                    Icons.account_circle, 'Username', user.username!),
                _buildDetailRow(Icons.email, 'Email', user.email!),
                _buildDetailRow(Icons.phone, 'Phone', user.phone!),
                _buildDetailRow(Icons.language, 'Website', user.website!),
                _buildDetailRow(Icons.location_on, 'Address',
                    '${user.address!.street}, ${user.address!.suite}, ${user.address!.city}, ${user.address!.zipcode}'),
                _buildDetailRow(Icons.business, 'Company', user.company!.name!),
                _buildDetailRow(
                    Icons.work, 'Company Phrase', user.company!.catchPhrase!),
                _buildDetailRow(
                    Icons.article, 'Company Business', user.company!.bs!),
                const Divider(height: 30, thickness: 2),
                const Text(
                  'ToDos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                userDataProvider.isLoading
                    ? const CircularProgressIndicator()
                    : userDataProvider.todos.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userDataProvider.todos.length,
                            itemBuilder: (context, todoIndex) {
                              final todo = userDataProvider.todos[todoIndex];
                              return ListTile(
                                leading: Icon(
                                  todo.completed!
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: todo.completed!
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(todo.title!),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                            'No ToDos available',
                            style: TextStyle(color: Colors.black),
                          )),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
