import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/models/post.dart';
import 'package:upsa/utils/server.dart';

class Dashboard extends StatefulWidget {
  static const namedRoute = "dashboard-screen";
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}
class _DashboardState extends State<Dashboard> {
  List<Post> _posts = [];
  String _error = "";


  @override
  void initState() {
    super.initState();
    _getData();
    print(Provider.of<AppNotifier>(context, listen: false).count);
  }
  
  void _getData() async {
    try {
      _posts = (await ApiService().getPosts())!;
      Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {
        _posts = _posts;
        _error = "";
      }));
    } on Exception catch (e) {
      _error = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          _posts.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    Post data = _posts[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(5.0),
                      title: Text(data.title),
                      subtitle: Text(data.description),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text((data.id).toString()),
                      ),
                    );
                  }
                ),
              ),
            Consumer<AppNotifier>(
              builder: (context, appState, child) {
                return Column(
                  children: [
                    Text('Count: ${appState.count}'),
                    Text('Is Logged In: ${appState.isLoggedIn}'),
                  ],
                );
              },
            ),

        ],
      ),
    );
  }
}
