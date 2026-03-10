import 'package:flutter/material.dart';
// import 'package:login_with_rive_animation/main.dart'; // Eliminado si causa error de importación circular
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

  //4.1 CREAR LOS CONTROLES(PARA MANIPUALAR EL TEXTO ESCRITO)
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    // Nota: Se corrigió el regex agregando .* para que las búsquedas sean globales
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    // Recalcular errores
    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError = isValidPassword(pass)
        ? null
        : 'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 caracter especial';

    // 4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

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
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(
            width: size.width,
            height: 250, // Ajustado para mejor visibilidad
            child: RiveAnimation.asset(
              'assets/animated_login_bear.riv', // Asegúrate de que la ruta sea correcta
              stateMachines: const ['Login Machine'],
              //Al iniciar la animacion
              onInit: (artboard) {
                _controller = StateMachineController.fromArtboard(
                    artboard, 'Login Machine');

                //Verifica que inicio bien
                if (_controller == null) return;
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
            //4.8 ENLAZAR CONTROLLER AL TEXTFIELD
            controller: _emailCtrl,
            //1.3 ASIGANASR EL FOCUSNODE AL TEXTFIELD
            focusNode: _emailFocusNode,
            onChanged: (value) {
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
              final look =
                  (value.length / 30.0 * 100.0).clamp(0.0, 100.0); // Clap es el rango (abrazadera)
              _numLook?.value = look;
              
              //3.3 DEBOUNCE: SU VUELVE A TECLEAR, REINIIA EL CONTADOR
              //CANCELAR CUALQUIEN TIMER EXISTENTE
              _typingDebounce?.cancel();
              //CREAR NUEVO TIMER
              _typingDebounce = Timer(const Duration(seconds: 2), () {
                //SI SE CIERRA LA PANTALLA LIBERA EL TIMER
                if (!mounted) return;
                //MIRA NEUTRA
                _isChecking!.change(false);
              });
            },
            //Para mostrar un tipo de teclado
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              //4.9 ENLAZAR CONTROLLER AL TEXTFIELD MOSTRAR EL TEXTO DE ERROR
              errorText: emailError,
              hintText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          //TextFiel de contraseña
          TextField(
            //4.8 ENLAZAR CONTROLLER AL TEXTFIELD
            controller: _passCtrl,
            //1.3 ASIGANASR EL FOCUSNODE AL TEXTFIELD
            focusNode: _passowrdFocusNode,
            onChanged: (value) {
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
              //4.9 ENLAZAR CONTROLLER AL TEXTFIELD MOSTRAR EL TEXTO DE ERROR
              errorText: passError,
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
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
          const SizedBox(height: 10), //ESPACIO ENTRE CAMPOS

          //TEXTO DE "OLVIDE MI CONTRASEÑA"
          SizedBox(
            width: size.width,
            child: const Text(
              "Forgot password?",
              //ALINIARLO A LA DERECHA
              textAlign: TextAlign.right,
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 10),
          MaterialButton(
            //TOMA TODOS EL ANCHO DE BANDA POSIBLE
            minWidth: size.width,
            height: 50,
            color: const Color.fromARGB(255, 173, 0, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: _onLogin,
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          //NO TIENES CUENTA?
          SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        //SUBRAYADO
                        decoration: TextDecoration.underline,
                        //PARA NEGRITAS
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    )));
  }

  //1.4 LIBERAR MEMORIA RECURSOS/RECURSOS AL SALIR DE LA PANTALLA
  @override
  void dispose() {
    //4.11 LIMPIAR CONTROLERS
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocusNode.dispose();
    _passowrdFocusNode.dispose();
    _typingDebounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}