import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:test/services/location_service/location_service.dart';
import 'package:test/views/detail/user_detail.dart';
import '../../controllers/provider/user_details_provider.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, this.location});

  Position? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        centerTitle: true,
        actions: [
          const Icon(Icons.location_on),
          StreamBuilder<String>(
            stream: LocationService().getPlaceName(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Text('Fetching..');
              } else if (snap.hasError) {
                return const Text('Not available');
              }
              return Text(snap.data ?? 'Not available');
            },
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            Provider.of<UserDataProvider>(context, listen: false)
                .initUserData(isrefresh: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Consumer<UserDataProvider>(
            builder: (context, userDataProvider, _) {
              if (userDataProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (userDataProvider.error != null &&
                  userDataProvider.userData.isEmpty) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.89,
                    child: Center(child: Text('${userDataProvider.error}')),
                  ),
                );
              } else if (userDataProvider.userData.isEmpty) {
                return const Center(child: Text('No data available'));
              } else {
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: userDataProvider.userData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        leading: const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          userDataProvider.userData[index].name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Email: ${userDataProvider.userData[index].email!}',
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Username: ${userDataProvider.userData[index].username!}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UserDetail(
                              user: userDataProvider.userData[index],
                              location: location,
                            ),
                          ));
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
