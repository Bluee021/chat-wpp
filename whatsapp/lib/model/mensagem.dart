class Mensagem {
  String _idUsuario = '';
  late String _mensagem = '';
  late String _urlMensagem = '';
  late String _tipo = '';
  late String _data;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'idUsuario': this.idUsuario,
      'mensagem': this.mensagem,
      'urlMensagem': this.urlMensagem,
      'tipo': this.tipo,
      'data': this.data,
    };
    return map;
  }

  String get data => _data;

  set data(String value) {
    _data = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  String get urlMensagem => _urlMensagem;

  set urlMensagem(String value) {
    _urlMensagem = value;
  }
}
