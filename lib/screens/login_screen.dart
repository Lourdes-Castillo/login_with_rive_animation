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

  //Crear el cerebro de la animacion
  StateMachineController? _controller;
  //SMI: State Machine Input
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

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
                child: RiveAnimation.asset(
                    'assets/animated_login_bear.riv', // Asegúrate de que la ruta sea correcta
                    stateMachines: ['Login Machine'],
              //Al iniciar la animacion
              onInit: (artboard) {
                _controller = StateMachineController.fromArtboard(
                  artboard, 
                  'Login Machine'  
                );

                //Verifica que inicio bien
                if(_controller == null) return;
                //Agrega el controlador al tablero/escenario
                artboard.addController(_controller!);
                //Vincular variables
                _isChecking = _controller!.findSMI('isChecking');
                _isHandsUp = _controller!.findSMI('isHandsUp');
                _trigSuccess = _controller!.findSMI('trigSuccess');
                _trigFail = _controller!.findSMI('trigFail');
              },
                  ),
                ),
              const SizedBox(height: 18),
              //CAMPO DE TEXTO EMAIL
              TextField(
                onChanged: (value){
                  if (_isHandsUp != null) {
                    //No tapes los ojos al ver email
                    _isHandsUp!.change(false);
                  }
                  //Si isChecking no es nulo
                  if (_isChecking == null) return;
                  //Activar el modo chismos
                  _isChecking!.change(true);
                },
                //Para un tipo de teclado
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
              //TextFiel de contraseña
              TextField(
                onChanged: (value){
                  if (_isChecking != null) {
                    //No quiero modo chismo
                    _isChecking!.change(false);
                  }
                  //Si isHandsUp no es nulo
                  if (_isHandsUp == null) return;
                  //Activar el modo chismos
                  _isHandsUp!.change(true);
                },
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