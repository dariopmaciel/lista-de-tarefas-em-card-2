import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snackbar/snackbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;
  final TextEditingController _controll = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data!);
      });
    });
  }

  void _addTodoList() {
    setState(
      () {
        Map<String, dynamic> newToDo = {}; //Map();
        newToDo["title"] = _controll.text;
        _controll.text = "";
        newToDo["ok"] = false;
        _toDoList.add(newToDo);
        _saveData();
      },
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    //ordenação
    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Lista de Tarefas 2"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            UserAccountsDrawerHeader(
              accountName: Text(
                "Dario",
              ),
              accountEmail: Text(
                "dariodepaulamaciel@hotmail.com",
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: Text(
                  "D",
                ),
              ),
            ),
            ListTile(
              title: Text(
                  "Este projeto foi criado como um experimento de aprendizado."),
            ),
            ListTile(
              title: Text("Obrigado por sua visualização."),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  //'Expanded' expande até a máxima largura possivel
                  child: TextField(
                    controller: _controll,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Nova Tarefa:",
                      hintText: "Ex. Estudar Flutter",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff00d7f3),
                          width: 3,
                        ),
                      ),
                      labelStyle: TextStyle(color: Color(0xff00d7f3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodoList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff00d7f3), //cor em hexadecimal
                    //expaçamento entre txt e borda do btn
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.add, size: 30),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 5),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _getFile() async {
    final diretory = await getApplicationDocumentsDirectory();
    return File("${diretory.path}/data!.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      print("ERRO-ERRO");
      return null;
    }
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.redAccent,
        child: const Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: Container(
        color: Colors.grey[300],
        child: CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          onChanged: (c) {
            setState(() {
              _toDoList[index]["ok"] = c;
              _saveData();
            });
          },
        ),
      ),
      onDismissed: (direction) {
        setState(
          () {
            _lastRemoved = Map.from(_toDoList[index]);
            _lastRemovedPos = index;
            _toDoList.removeAt(index);
            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
              duration: const Duration(seconds: 5),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
          },
        );
      },
    );
  }
}
