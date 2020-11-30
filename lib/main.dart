import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(SAF());
}

class SAF extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAF Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Weapon> _weapons;
  TextEditingController searchController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      setState(() {
        _search = searchController.text;
      });
    });
    loadWeapons();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
          )
        ),
        body: _buildList(),
      )
    );
  }

  Widget _buildList() {
    return Builder(
      builder: (context) {
        if ((_weapons ?? []).length == 0) {
          return Center(child: CircularProgressIndicator());
        }
        final filtered = _weapons.where((element) => element.contains(_search)).toList();
        return Scrollbar(
          child: ListView.builder(
            itemCount: filtered.length * 2,
            itemBuilder: (context, idx) {
              if (idx.isOdd) return Divider();
              final index = idx ~/ 2;
              return ListTile(
                leading: Text(filtered[index].rarity),
                title: Text(filtered[index].name),
                subtitle: Row(
                  children: [
                    Text(filtered[index].saf),
                    Text(filtered[index].dropString),
                  ],
                ),
              );
            },
          )
        );
      }
    );
  }

  Future<void> loadWeapons() async {
    List weaponsJson = jsonDecode(await DefaultAssetBundle.of(context).loadString('data/weapons.json')) as List;
    List weapons = weaponsJson.map<Weapon>((weapon) => Weapon.fromJson(weapon)).toList();
    weapons.sort((a,b) => a.name.compareTo(b.name));
    setState(() {
      _weapons = weapons;
    });
  }
}


class Weapon {
  final String category;
  final String rarity;
  final String name;
  final String saf;
  final String dropString;
  final List<String> drop;
  

  Weapon({this.category, this.rarity, this.name, this.saf, this.dropString, this.drop});
  
  factory Weapon.fromJson(Map raw) => Weapon(
    category: raw['category'],
    rarity: raw['rarity'],
    name: raw['name'],
    saf: raw['saf'],
    dropString: raw['drop'],
    drop: raw['drop'].split('\n')
  );

  bool contains(String search) {
    return category.toLowerCase().contains(search) || rarity.toLowerCase().contains(search) || name.toLowerCase().contains(search) || saf.toLowerCase().contains(search) || dropString.toLowerCase().contains(search);
  }
}