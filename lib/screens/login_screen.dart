import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 IMPORTA EL TIEMPO/TIMER

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

  //2.1 VARIABLE PARA EL RECORRIDO DE LA MIRADA
  SMINumber? _numLook; 


  //1.1 CREAR VARIABLES PARA FOCUSNODE
  final _emailFocusNode = FocusNode();
  final _passowrdFocusNode = FocusNode();

  //3.2 TIMER PATA DETENER MIRAD AL DEJAR DE ESCRIBIR
  Timer? _typingDebounce;


  //1.2 LISTENERS (OYENTE/CHISMOSOS)

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //Virificar que no sea nulo
        if (_isHandsUp != null) {
          //Manos abajo en el email
          _isHandsUp!.change(false);
          //2.2 MIRADA NEUTRAL
          _numLook?.value = 50.0;
        }
      }
    });
    _passowrdFocusNode.addListener(() {
      //Maanos arriba en password
      _isHandsUp?.change(_passowrdFocusNode.hasFocus);
    });

  }

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
                //2.3 ENLAZAR O VINCULAR numLOOK LA MIRADA
                _numLook = _controller!.findSMI('numLook');

              },
                  ),
                ),
              const SizedBox(height: 18),
              //CAMPO DE TEXTO EMAIL
              TextField(
                //1.3 ASIGANASR EL FOCUSNODE AL TEXTFIELD
                focusNode: _emailFocusNode,
                onChanged: (value){
                  if (_isHandsUp != null) {
                    //No tapes los ojos al ver email
                    //_isHandsUp!.change(false);
                  }
                  //Si isChecking no es nulo
                  if (_isChecking == null) return;
                  //Activar el modo chismos
                  _isChecking!.change(true);
                  //2.4 IMPLEMENTAR NUMLOOK
                  //AJUSTES DE LIMITES DE 0 A 100
                  //80 COMO MEDIDA DE CALIBRACIÓN
                  //CLAP MARACA EL RANGO
                  final look = (value.length/90.0*100.0)
                  .clamp(0.0, 100.0); //  Clap es el rango (abrazadera)
                  _numLook?.value = look;
                  //3.3 DEBOUNCE: SU VUELVE A TECLEAR, REINIIA EL CONTADOR
                  //CANCELAR CUALQUIEN TIMER EXISTENTE
                  _typingDebounce?.cancel();
                  //CREAR NUEVO TIMER
                  _typingDebounce = Timer(
                    const Duration(seconds: 2), 
                    () {
                      //SI SE CIERRA LA PANTALLA LIBERA EL TIMER
                      if(!mounted) return;
                      //MIRA NEUTRA 
                      _isChecking!.change(false);
                      });
            
                },
                //Para mostrar un tipo de teclado
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
                //1.3 ASIGANASR EL FOCUSNODE AL TEXTFIELD
                focusNode: _passowrdFocusNode,
                onChanged: (value){
                  if (_isChecking != null) {
                    //No quiero modo chismo
                    //_isChecking!.change(false);
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
            ],
          ),
        ))

    );
  }
  //1.4 LIBERAR MEMORIA RECURSOS/RECURSOS AL SALIR DE LA PANTALLA
  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passowrdFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
