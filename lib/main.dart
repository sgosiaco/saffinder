import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:saffinder/models.dart';

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
  Map<String, Augment> _augments;
  List<String> _keys;
  TextEditingController _searchController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController.addListener(() {
      setState(() {
        _search = '';
        _searchController.text = '';
      });
    });
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text;
      });
    });
    loadJSON();
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
              List<Widget> drops = [
                Text('Drop info', style: TextStyle(fontWeight: FontWeight.bold),)
              ];
              filtered[index].drop.forEach((element) {
                if (filtered[index].dropString == '') {
                  drops.add(Text('Not available'));
                } else {
                  drops.add(Text(element));
                }
              });
              return ExpansionTile(
                key: PageStorageKey(filtered[index].name),
                leading: filtered[index].image,
                title: Text(filtered[index].rarityName),
                subtitle: Text('${filtered[index].saf}'),
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              Text('Augment Info', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('${filtered[index].safEffect}')
                            ]
                          ),
                        ),
                        Flexible(child: Column(children: drops),)
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: 'Lookup on Arks-Visiphone',
                      icon: Icon(Icons.search),
                      onPressed: () {
                        filtered[index].gotoURL();
                      },
                    ),
                  )
                ],
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
        final filtered = _keys.where((element) => _augments[element].contains(_search.toLowerCase())).toList();
        return Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            itemCount: filtered.length * 2,
            itemBuilder: (context, idx) {
              if (idx.isOdd) return Divider(thickness: 2);
              final index = idx ~/ 2;
              final augment = filtered[index];
              final weapons = _augments[augment].weapons;
              List<Widget> children = [];
              weapons.forEach((element) {
                children.add(ListTile(
                  leading: element.image,
                  title: Text(element.rarityName),
                  subtitle: Row(
                    children: [
                      Text(element.dropString),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Lookup on Arks-Visiphone',
                    icon: Icon(Icons.search),
                    onPressed: () {
                      element.gotoURL();
                    },
                  ),
                ));
              });
              return ExpansionTile(
                key: PageStorageKey(_augments[augment].name),
                title: Text(_augments[augment].name),
                subtitle: Text(_augments[augment].effect),
                children: children,
              );
            },
          )
        );
      }
    );
  }

  Future<void> loadJSON() async {
    List augmentsJson = jsonDecode(await DefaultAssetBundle.of(context).loadString('data/augments.json')) as List;
    List augments = augmentsJson.map<Augment>((augment) => Augment.fromJson(augment)).toList();

    List weaponsJson = jsonDecode(await DefaultAssetBundle.of(context).loadString('data/weapons.json')) as List;
    List<Weapon> weapons = weaponsJson.map<Weapon>((weapon) => Weapon.fromJson(weapon)).toList();
    weapons.sort((a,b) => a.name.compareTo(b.name));

    Map<String, Augment> augmentsMap = Map();
    augments.forEach((affix) {
      augmentsMap.putIfAbsent(affix.lower, () => affix);
    });

    Map<String, Augment> safMap = Map();
    Set<String> bad = Set();
    for (int i = 0; i < weapons.length; i++) {
      try {
        weapons[i].safEffect = augmentsMap[weapons[i].lower].effect;
        safMap.update(
          weapons[i].lower, 
          (value) {
            value.weapons.add(weapons[i]);
            return value;
          },
          ifAbsent: () {
            augmentsMap[weapons[i].lower].weapons.add(weapons[i]);
            return augmentsMap[weapons[i].lower];
          }
        );
      } catch (e) {
        //print('failed to get saf for ${weapons[i].name} ${weapons[i].saf}');
        bad.add(weapons[i].saf);
        safMap.update(
          weapons[i].lower, 
          (value) {
            value.weapons.add(weapons[i]);
            return value;
          },
          ifAbsent: () {
            final na = Augment(name: weapons[i].saf, effect: 'N/A');
            na.weapons.add(weapons[i]);
            return na;
          }
        );
        continue;
      }
    }

    bad.forEach((element) {
      print('Failed to get saf $element');
    });

    List keys = safMap.keys.toList()..sort((a,b) => a.compareTo(b));
    setState(() {
      _weapons = weapons;
      _augments = safMap;
      _keys = keys;
    });
  }
}



