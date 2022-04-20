import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/cadastro.dart';
import 'package:whatsapp/home.dart';
import 'package:whatsapp/model/usuario.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  var mensagemErro = "";

  validarLogin() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (senha.isNotEmpty) {
        setState((() => mensagemErro = ""));
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        logarUsuario(usuario);
      } else {
        setState((() => mensagemErro = "insira a senha"));
      }
    } else {
      setState((() => mensagemErro = "verifique se o email está correto"));
    }
  }

  logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((user) {
      Navigator.pushReplacementNamed(context, '/home');
    }).catchError((error) {
      setState((() => mensagemErro = "verifique se os dados estão corretos"));
    });
  }

  Future verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    // auth.signOut();
    User? usuariologado = await auth.currentUser;
    print('logado:  ' + usuariologado.toString());
    if (usuariologado != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    verificarUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Color(0xff075E54)),
          padding: EdgeInsets.all(16),
          child: Center(
              child: SingleChildScrollView(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    'images/logo.png',
                    width: 200,
                    height: 150,
                  )),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  autofocus: true,
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'E-mail',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  obscureText: true,
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'senha',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32))),
                  child: Text(
                    "Entrar",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    validarLogin();
                  },
                ),
              ),
              Center(
                child: GestureDetector(
                  child: Text(
                    "Não tem conta? Cadastre-se!",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/cadastro');
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    mensagemErro,
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              )
            ],
          )))),
    );
  }
}
