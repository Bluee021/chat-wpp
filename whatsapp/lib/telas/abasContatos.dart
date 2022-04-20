import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/usuario.dart';

import '../model/Conversas.dart';

class AbaContatos extends StatefulWidget {
  const AbaContatos({Key? key}) : super(key: key);

  @override
  State<AbaContatos> createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String? _idUsuarioLogado;
  String? _emailLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection('usuarios').get();

    List<Usuario> listaUsuarios = [];

    for (DocumentSnapshot item in querySnapshot.docs) {
      Map dados = item.data() as Map;
      Usuario usuario = Usuario();
      if (dados['email'] == _emailLogado) continue;
      usuario.idUsuario = item.id;
      usuario.nome = dados['nome'];
      usuario.email = dados['email'];
      usuario.urlImagem =
          (dados['urlImagem'] == null) ? '' : dados['urlImagem'];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado!.uid;
      _emailLogado = usuarioLogado.email;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return (Center(
                child: Column(
                  children: [
                    Text('Carregando contatos'),
                    CircularProgressIndicator()
                  ],
                ),
              ));
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              return (ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: ((context, index) {
                    List<Usuario> listaItens = snapshot.data!;
                    Usuario usuario = listaItens[index];
                    return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, '/mensagens',
                              arguments: usuario);
                        },
                        contentPadding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        leading: CircleAvatar(
                          maxRadius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: usuario.urlImagem != ''
                              ? NetworkImage(usuario.urlImagem)
                              : null,
                        ),
                        title: Text(
                          usuario.nome,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ));
                  })));
              break;
          }
        });
  }
}
