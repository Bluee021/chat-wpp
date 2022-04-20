import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  late String _nome;
  late String _mensagem;
  late String _caminhoFoto;
  late String _idRemetente;
  late String _idDestinatario;
  late String _tipoMensagem;

  Conversa();

  String get idRemetente => _idRemetente;

  set idRemetente(String n) => _idRemetente = n;

  String get idDestinatario => _idDestinatario;

  set idDestinatario(String n) => _idDestinatario = n;

  String get tipoMensagem => _tipoMensagem;

  set tipoMensagem(String n) => _tipoMensagem = n;

  String get nome => _nome;

  set nome(String n) => _nome = n;

  String get mensagem => _mensagem;

  set mensagem(String n) => _mensagem = n;

  String get caminhoFoto => _caminhoFoto;

  set caminhoFoto(String n) => _caminhoFoto = n;

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    print("conversa: entrei");
    await db
        .collection('conversas')
        .doc(this.idRemetente)
        .collection('ultima_conversa')
        .doc(this.idDestinatario)
        .set(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this._idRemetente,
      "idDestinatario": this._idDestinatario,
      "nome": this._nome,
      "mensagem": this._mensagem,
      "caminhoFoto": this._caminhoFoto,
      "tipoMensagem": this._tipoMensagem,
    };
    print('conversa:  ' + map.toString());
    return map;
  }
}
