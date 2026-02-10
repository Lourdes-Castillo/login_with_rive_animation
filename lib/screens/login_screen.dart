import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Controlar para mostra o ocultar la contraseña
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la memoria 
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      //Evitar que se quite el esapacio del nudge
      body: SafeArea(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: const RiveAnimation.asset('animated_login_bear.riv'),
              ),
              const SizedBox(height: 18),
              TextField(
                //Para un tipo de yeclafo
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)  
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password' ,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off
                      ),
                      onPressed: () {
                        //Refrescar el Icono
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
              )
            ],
          ),
        ))

    );
  }
}