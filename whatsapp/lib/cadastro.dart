import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/home.dart';
import 'package:whatsapp/model/usuario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  var mensagemErro = "";

  validarCampos() {
    var senha = _controllerSenha.text;
    var nome = _controllerNome.text;
    var email = _controllerEmail.text;

    if (nome.isNotEmpty) {
      if (email.contains('@')) {
        if (senha.length >= 6) {
          setState(() {
            mensagemErro = '';
          });

          Usuario usuario = Usuario();

          usuario.nome = nome;
          usuario.senha = senha;
          usuario.email = email;
          cadastrarUsuario(usuario);
        } else {
          setState(() {
            mensagemErro = 'A senha precisa ter pelo menos 6 caracteres';
          });
        }
      } else {
        setState(() {
          mensagemErro = "Insira um email válido";
        });
      }
    } else {
      setState(() {
        mensagemErro = "Preencha o campo nome";
      });
    }
  }

  cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    //criar o usuario atraves do email e senha
    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      //se nao obtiver errros, iremos criar tambem ira salvar no banco de dados
      FirebaseFirestore db = FirebaseFirestore.instance;

      db
          .collection('usuarios')
          .doc(firebaseUser.user!.uid)
          .set(usuario.toMap());
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }).catchError((error) {
      setState(() {
        mensagemErro = 'verifique os campos e tente novamente';
        print('erro no app:  $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        centerTitle: true,
      ),
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
                    'images/usuario.png',
                    width: 120,
                    height: 100,
                  )),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  autofocus: true,
                  controller: _controllerNome,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: 'Nome',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  controller: _controllerEmail,
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
                  keyboardType: TextInputType.text,
                  controller: _controllerSenha,
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
                    "Cadastrar",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    validarCampos();
                  },
                ),
              ),
              Center(
                child: Text(
                  mensagemErro,
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            ],
          )))),
    );
  }
}
