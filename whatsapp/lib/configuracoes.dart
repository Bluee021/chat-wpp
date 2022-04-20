import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

const URLPADRAO =
    'https://firebasestorage.googleapis.com/v0/b/whatsapp-2cb5f.appspot.com/o/perfil%2Fusuario.png?alt=media&token=82970188-6100-4c0b-b9bf-f79b1916f58d';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  String _idUsuario = '';
  bool _subindoImagem = false;
  File? _imagemSelecionada;
  String _urlImagem = '';

  Future _recuperarImagem(String origem) async {
    final imagem = await ImagePicker().pickImage(
        source:
            (origem == 'camera') ? ImageSource.camera : ImageSource.gallery);
    if (imagem == null) return;
    final imageTemp = File(imagem.path);
    setState(() {
      this._imagemSelecionada = imageTemp;
      print('path: ' + _imagemSelecionada.toString());
      _uploadImagem();
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref('perfil');
    Reference arquivo = pastaRaiz.child('${_idUsuario}.jpg');
    UploadTask task = arquivo.putFile(_imagemSelecionada!);

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('estado: ' + snapshot.state.toString());
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
    _atualizarUrlFirestore(url);
    setState(() {
      _urlImagem = url;
    });
  }

  _atualizarUrlFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dados = {
      'urlImagem': url,
    };

    db.collection('usuarios').doc(_idUsuario).update(dados);
  }

  _atualizarNomeFirestore() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dados = {
      'nome': _controllerNome.text,
    };

    db.collection('usuarios').doc(_idUsuario).update(dados);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    var usuarioLogado = await auth.currentUser;
    setState((() => _idUsuario = usuarioLogado!.uid));

    var snapshot = await db.collection('usuarios').doc(_idUsuario).get();
    Map<String, dynamic>? dados = snapshot.data();

    _controllerNome.text = dados?['nome'];
    if (dados?['urlImagem'] != null) {
      setState(() => _urlImagem = dados?['urlImagem']);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            _subindoImagem ? CircularProgressIndicator() : Container(),
            SizedBox(width: 20),
            CircleAvatar(
                radius: 100,
                backgroundColor: Colors.grey,
                // backgroundImage: NetworkImage(
                //     'https://firebasestorage.googleapis.com/v0/b/whatsapp-2cb5f.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=6089bbb4-2490-4052-8a22-2b37809726f1')
                backgroundImage:
                    (_urlImagem != null) ? NetworkImage(_urlImagem) : null),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      _recuperarImagem('camera');
                    },
                    child: Text("Câmera")),
                TextButton(
                    onPressed: () {
                      _recuperarImagem('galeria');
                    },
                    child: Text("Galeria")),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
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
              padding: EdgeInsets.only(top: 10, bottom: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32))),
                child: Text(
                  "Salvar",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: _atualizarNomeFirestore,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
