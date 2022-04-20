import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/model/usuario.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  State<AbaConversas> createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> listaConversas = [];
  final _controllerStream = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _idUsuario;

  Stream<QuerySnapshot>? _adicionarListenerConversas() {
    final stream = db
        .collection('conversas')
        .doc(_idUsuario)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controllerStream.add(dados);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = await auth.currentUser;
    setState((() {
      _idUsuario = usuarioLogado!.uid;
    }));
    _adicionarListenerConversas();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controllerStream.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _controllerStream.stream,
        builder: (_, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Column(
                children: [
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ));
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data!;

              if (snapshot.hasError) {
                return Text('Erro ao carregar dados');
              } else {
                if (querySnapshot.docs.length == 0) {
                  return Center(
                    child: Text(
                      "Você não tem nenhuma mensagem ainda :(",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return ListView.builder(
                    itemCount: querySnapshot.docs.toList().length,
                    itemBuilder: ((context, index) {
                      var conversas = querySnapshot.docs.toList();
                      var conversa = conversas[index];
                      String urlImagem = conversa['caminhoFoto'];
                      String tipo = conversa['tipoMensagem'];
                      String mensagem = conversa['mensagem'];
                      String nome = conversa['nome'];
                      String idDestinarario = conversa['idDestinatario'];

                      Usuario usuario = Usuario();
                      usuario.nome = nome;
                      usuario.urlImagem = urlImagem;
                      usuario.idUsuario = idDestinarario;
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, '/mensagens',
                              arguments: usuario);
                        },
                        contentPadding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        leading: CircleAvatar(
                          maxRadius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: urlImagem != null
                              ? NetworkImage(urlImagem)
                              : null,
                        ),
                        title: Text(
                          nome,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          tipo == 'texto' ? mensagem : "Imagem...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }));
              }
          }
        });
  }
}
