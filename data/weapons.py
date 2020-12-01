import json
import requests
import requests_cache
import time

class Weapon:
    def __init__(self, category, rarity, name, saf, drop):
        self.category = category
        self.rarity = rarity
        self.name = name
        self.saf = saf
        self.drop = drop

weapons = [
    'Swords_List',
    'Wired_Lances_List',
    'Partisans_List',
    'Twin_Daggers_List',
    'Double_Sabers_List',
    'Knuckles_List',
    'Katanas_List',
    'Soaring_Blades_List',
    'Gunblade_List',
    'Assault_Rifles_List',
    'Launchers_List',
    'Twin_Machine_Guns_List',
    'Bows_List',
    'Rods_List',
    'Talises_List',
    'Wands_List',
    'Jet_Boots_List',
]

items = []
requests_cache.install_cache('cache')

for weapon in weapons:
    print(f'Processing {weapon}')
    page = requests.get(f'https://pso2na.arks-visiphone.com/index.php?title={weapon}&action=edit')
    info = page.content.decode().split('{{Weapon_Listing}}')[1].replace(u'\u2605', '*').replace('&lt;/table>', '').replace('&amp;', '&')
    lines = info.split('\n')
    #f = open(f'{weapon}.txt', 'w')
    #output = ''

    for index, line in enumerate(lines):
        if len(line) > 5 and not line.startswith('{{WpnRow'):
            lines[index - 1] += line
            lines[index] = ''

    for line in lines:
        attributes = line.split('|')
        if len(attributes) < 5:
            continue
        rarity = line.split('rarity')[1].split('|')[0].split('=')[1].strip()
        name = line.split('name')[1].split('|')[0].split('=')[1].strip()
        factors = line.split('AugmentFactors')
        if len(factors) < 2:
            print(f'{name} HAS NO FACTORS!')
            continue
        saf = factors[1].split('|')[1].replace('}}', '').split('&lt;')[0].replace('Resolve', 'Will').replace('Revenant', 'Spectre').replace('Lucentrush', 'Apparition').strip()
        saf = saf.replace('Spectre Lucentboon', 'Lustrous Spectre').replace('Shield of the Spectre', 'Spectre Shield')
        if 'S2' in saf and 'Spectre' in saf:
            saf = saf.replace('\'s', '')
        drop = attributes[-1].replace('}}', '').replace('[[', '').replace(']]', '').replace('&lt;br>', '\n').strip()
        if '&lt;/small' in drop:
            drop = line.split('&lt;small>')[1].replace('[[', '').replace(']]', '').replace('&lt;br>', '\n').replace('Challenge_Mile_Shop|', '').split('&lt;/small>')[0].strip()
        
        #print(f'{rarity} | {name} | {saf} | {drop}')
        #output += f'{rarity} | {name} | {saf} | {drop}\n'
        items.append(Weapon(weapon.replace('_List', '').replace('_', ' '), rarity, name, saf, drop))
    
    #f.write(output)
    #print(f'Wrote {len(output)} characters to {weapon}.txt')
    #f.close()
    #time.sleep(2) # Be nice and wait 2 sec before next request

print('Writing json')
f = open('weapons.json', 'w')
f.write(json.dumps([ob.__dict__ for ob in items]))
f.close()
