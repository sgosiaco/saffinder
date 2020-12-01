import 'package:url_launcher/url_launcher.dart';

class Augment {
  final String name;
  final String effect;
  List<Weapon> weapons = [];

  Augment({this.name, this.effect});

  factory Augment.fromJson(Map raw) => Augment(
    name: raw['name'],
    effect: raw['effect']
  );

  get lower => name.toLowerCase().splitMapJoin(RegExp('([a-z, 0-9])'), onNonMatch: (t) => '').replaceAll(RegExp('\\s'), '');

  bool contains(String search) {
    final weapon = weapons.firstWhere((element) => element.contains(search), orElse: () => null);
    return name.toLowerCase().contains(search) || effect.toLowerCase().contains(search) || weapon != null;
  }
}

class Weapon {
  final String category;
  final String rarity;
  final String name;
  final String saf;
  final String dropString;
  final List<String> drop;
  String safEffect = '';
  

  Weapon({this.category, this.rarity, this.name, this.saf, this.dropString, this.drop});
  
  factory Weapon.fromJson(Map raw) => Weapon(
    category: raw['category'],
    rarity: raw['rarity'],
    name: raw['name'],
    saf: raw['saf'],
    dropString: raw['drop'],
    drop: raw['drop'].split('\n')
  );

  get rarityName => '$rarity\u{2605} $name';
  get url => 'https://pso2na.arks-visiphone.com/wiki/${name.replaceAll(' ', '_')}';
  get lower => saf.toLowerCase().splitMapJoin(RegExp('([a-z, 0-9])'), onNonMatch: (t) => '').replaceAll(RegExp('\\s'), '');

  Future<void> gotoURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    } 
  }

  bool contains(String search) {
    return category.toLowerCase().contains(search) || rarity.toLowerCase().contains(search) || name.toLowerCase().contains(search) || saf.toLowerCase().contains(search) || dropString.toLowerCase().contains(search);
  }
}