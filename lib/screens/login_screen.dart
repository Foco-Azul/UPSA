import 'package:flutter/material.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
    import 'package:upsa/screens/signup_screen.dart';
    import 'package:upsa/screens/dashboard_screen.dart';
    import 'package:upsa/utils/server.dart';
    import 'package:upsa/models/user.dart';
    import 'package:provider/provider.dart';

    class Login extends StatefulWidget {
      static const namedRoute = "login-screen";
      const Login({Key? key}) : super(key: key);
    
      @override
      
      State<Login> createState() => _LoginState();
       
      }
    
      class _LoginState extends State<Login> {
  String _email = "";
  String _password = "";
  String _error = "";
  bool _bandera = false;
  String prueba = "";
  
  @override
  void initState() {
    super.initState();
    _bandera = Provider.of<AppNotifier>(context, listen: false).isLoggedIn;
    //prueba = _bandera ? "true" : "false";
    //Provider.of<AppNotifier>(context, listen: false).incrementCount();

    print("holas3");
    Future.delayed(const Duration(seconds: 2), () {
  setState(() {
    print(Provider.of<AppNotifier>(context, listen: false).count);
    //prueba = Provider.of<AppNotifier>(context, listen: false).count.toString();
  });
});

    
  }
  
  void _login() async {
    print(Provider.of<AppNotifier>(context, listen: false).count);
    try {
      User user = (await ApiService().getUsers(_email, _password))!;
if (user == null) {
  setState(() {
    _error = "Your account does not exist.";
  });
} else {
  // Setear _isLoggedIn a true cuando el login es exitoso
  Provider.of<AppNotifier>(context, listen: false).login();
  Provider.of<AppNotifier>(context, listen: false).incrementCount();
  
  print("se ingreso a la cuenta");
  // Navigate to the dashboard screen.
  //Navigator.pushNamed(context, Dashboard.namedRoute);
}

    } on Exception catch (e) {
      setState(() {
        _error = e.toString().substring(11);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("holasassd");
    print(Provider.of<AppNotifier>(context, listen: false).count);
    prueba = Provider.of<AppNotifier>(context, listen: false).count.toString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                    ),
                    Text("Strapi App "+prueba),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
            if (_error.isNotEmpty)
              Column(
                children: [
                  Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email id as abc@gmail.com',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextButton(
                onPressed: () => _login(),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: () {
                // Navigate to the signup screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Signup()),
                );
              },
              child: const Text(
                'New user? Create Account',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
