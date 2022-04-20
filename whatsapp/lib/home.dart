import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/login.dart';
import 'package:whatsapp/telas/abasContatos.dart';
import 'package:whatsapp/telas/abasConversas.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> itensMenu = ["Configurações", "Deslogar"];
  String emailLogado = '';

  Future recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;

    setState(() {
      emailLogado = usuarioLogado!.email.toString();
    });
  }

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        Navigator.pushNamed(context, '/configuracoes');
        break;
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }

  Future _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    // auth.signOut();
    User? usuariologado = await auth.currentUser;
    if (usuariologado == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    recuperarDadosUsuario();
    verificarUsuarioLogado();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              PopupMenuButton<String>(
                  onSelected: _escolhaMenuItem,
                  itemBuilder: (context) {
                    return itensMenu.map((String item) {
                      return PopupMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList();
                  }),
            ],
            centerTitle: true,
            title: Text('WhatsApp'),
            bottom: TabBar(
              indicatorWeight: 4,
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: 'Conversas',
                ),
                Tab(
                  text: 'Contatos',
                )
              ],
            )),
        body: TabBarView(
          controller: _tabController,
          children: [
            AbaConversas(),
            AbaContatos(),
          ],
        ));
  }
}
