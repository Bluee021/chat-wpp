import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversas.dart';
import 'package:whatsapp/model/mensagem.dart';
import 'package:whatsapp/model/usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Mensagens extends StatefulWidget {
  const Mensagens({Key? key, required this.usuario}) : super(key: key);

  final Usuario usuario;

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  File? _Imagem;
  bool _subindoImagem = false;
  TextEditingController _controllerMensagem = TextEditingController();
  String? _idUsuario;
  String? _idDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;

  final _controllerStream = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot> _adicionarListenerMensagens() {
    final stream = db
        .collection('mensagens')
        .doc('${_idUsuario}')
        .collection('${_idDestinatario!}')
        .orderBy('data', descending: false)
        .snapshots();

    stream.listen((dados) {
      _controllerStream.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

    return _adicionarListenerMensagens();
  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;

    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuario!;
      mensagem.mensagem = textoMensagem;
      mensagem.urlMensagem = '';
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = 'texto';
      //salvar no id de quem enviou
      _salvarMensagem(_idUsuario!, _idDestinatario!, mensagem);

      //salvar para quem recebeu
      _salvarMensagem(_idDestinatario!, _idUsuario!, mensagem);

      //salvar conversa
      _salvarConversa(mensagem);

      _controllerMensagem.text = "";
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection('mensagens')
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
  }

  _enviarFoto() async {
    final imagem = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagem == null) return;
    final imageTemp = File(imagem.path);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref('mensagens');
    Reference arquivo = pastaRaiz.child(_idUsuario!).child('${nomeImagem}.jpg');
    UploadTask task = arquivo.putFile(imageTemp);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      // print('estado: ' + snapshot.state.toString());
      if (snapshot.state == TaskState.running) {
        _subindoImagem = true;
      } else if (snapshot.state == TaskState.success) {
        _subindoImagem = false;
      }
    });

    task.then((TaskSnapshot snapshot) {
      _recuperarUrl(snapshot);
    });
  }

  Future _recuperarUrl(TaskSnapshot snap) async {
    String url = await snap.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.data = Timestamp.now().toString();
    mensagem.idUsuario = _idUsuario!;
    mensagem.mensagem = "";
    mensagem.urlMensagem = url;
    mensagem.tipo = 'imagem';

    //salvar no id de quem enviou
    _salvarMensagem(_idUsuario!, _idDestinatario!, mensagem);

    //salvar para quem recebeu
    _salvarMensagem(_idDestinatario!, _idUsuario!, mensagem);

    //salvar conversa
    _salvarConversa(mensagem);
  }

  _salvarConversa(Mensagem msg) {
    print('entrei');
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuario!;
    cRemetente.idDestinatario = _idDestinatario!;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.usuario.nome;
    cRemetente.caminhoFoto = widget.usuario.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idDestinatario!;
    cDestinatario.idDestinatario = _idUsuario!;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.usuario.nome;
    cDestinatario.caminhoFoto = widget.usuario.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = await auth.currentUser;
    setState((() {
      _idUsuario = usuarioLogado!.uid;
      _idDestinatario = widget.usuario.idUsuario;
    }));
    // print('id usuario:   ' + _idUsuario!);
    _adicionarListenerMensagens();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    print('teste');
    var caixaMensagem = Container(
      padding: EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: TextField(
              controller: _controllerMensagem,
              autofocus: true,
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  hintText: "mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: _subindoImagem
                      ? CircularProgressIndicator()
                      : IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: _enviarFoto,
                        ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32))),
            ),
          )),
          FloatingActionButton(
              backgroundColor: Color(0xff075E54),
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              mini: true,
              onPressed: _enviarMensagem)
        ],
      ),
    );

    var stream = StreamBuilder<QuerySnapshot>(
        stream: _controllerStream.stream,
        builder: (context, snapshot) {
          var list = snapshot.data! ;

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text('Carregando contatos'),
                    CircularProgressIndicator(),
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Expanded(child: Text('Erro ao carregar dados'));
              } else {
                return Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: list.docs.length,
                        itemBuilder: (context, index) {
                          var mensagens = list.docs.toList();
                          var item = mensagens[index];
                          print('item:  ' + item['mensagem']);
                          Alignment alinhamento = Alignment.centerRight;
                          Color corMensagem = Color(0xffd2ffa5);

                          double larguraContainer =
                              MediaQuery.of(context).size.width * 0.8;
                          if (_idUsuario != item['idUsuario']) {
                            alinhamento = Alignment.centerLeft;
                            corMensagem = Colors.white;
                          }

                          return Align(
                            alignment: alinhamento,
                            child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Container(
                                  width: larguraContainer,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: corMensagem,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: item['tipo'] == 'texto'
                                      ? Text(
                                          item['mensagem'],
                                          style: TextStyle(fontSize: 18),
                                        )
                                      : Image.network(
                                          item['urlMensagem'],
                                          width: 200,
                                          height: 200,
                                        ),
                                )),
                          );
                        }));
              }
              break;
          }
        });

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            maxRadius: 20,
            backgroundColor: Colors.grey,
            backgroundImage: widget.usuario.urlImagem != null
                ? NetworkImage(widget.usuario.urlImagem)
                : null,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(this.widget.usuario.nome),
          ),
        ],
      )),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/bg.png'), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [stream, caixaMensagem],
                ))),
      ),
    );
  }
}
