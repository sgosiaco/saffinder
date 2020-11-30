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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final List<Tab> _tabs = [
    Tab(text: 'Augments'),
    Tab(text: 'Weapons'),
  ];
  TabController _tabController;

  List<Weapon> _weapons;
  Map<String, List<Weapon>> _augments;
  List<String> _keys;
  TextEditingController _searchController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text;
      });
    });
    loadWeapons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs
          )
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAugments(),
            _buildWeapons(),
          ],
        ),
      )
    );
  }

  Widget _buildWeapons() {
    return Builder(
      builder: (context) {
        if ((_weapons ?? []).length == 0) {
          return Center(child: CircularProgressIndicator());
        }
        final filtered = _weapons.where((element) => element.contains(_search.toLowerCase())).toList();
        return Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(filtered[index].dropString)
                    ),
                  ],
                ),
              );
            },
          )
        );
      }
    );
  }

  Widget _buildAugments() {
    return Builder(
      builder: (context) {
        if ((_weapons ?? []).length == 0) {
          return Center(child: CircularProgressIndicator());
        }
        final filtered = _keys.where((element) => element.toLowerCase().contains(_search.toLowerCase())).toList();
        return Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            itemCount: filtered.length * 2,
            itemBuilder: (context, idx) {
              if (idx.isOdd) return Divider(thickness: 2);
              final index = idx ~/ 2;
              final augment = filtered[index];
              final weapons = _augments[augment];
              List<Widget> children = [Text(augment)];
              weapons.forEach((element) {
                children.add(ListTile(
                  leading: Text(element.rarity),
                  title: Text(element.name),
                  subtitle: Row(
                    children: [
                      Text(element.dropString),
                    ],
                  ),
                ));
              });
              return Column(
                children: children,
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
    Map<String, List<Weapon>> augments = Map();
    weapons.forEach((weapon) {
      augments.update(
        weapon.saf, 
        (value) {
          value.add(weapon);
          return value;
        }, 
        ifAbsent: () {
          return [weapon];
        }
      );
    });
    List keys = augments.keys.toList()..sort((a,b) => a.compareTo(b));
    setState(() {
      _weapons = weapons;
      _augments = augments;
      _keys = keys;
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