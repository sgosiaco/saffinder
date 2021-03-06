import difflib
import os
import requests
import requests_cache

def patch(saf):
    out = (saf
        .replace('Resolve', 'Will')
        .replace('Revenant', 'Spectre')
        .replace('Spectre\'s Lucentboon', 'Lustrous Spectre') #S2: Lustrous Spectre
        .replace('Lucentrush', 'Apparition') #S2: Spectre Apparition
        .replace('Shield of the Spectre', 'Spectre Shield') #S2: Spectre Shield
        .replace('Lifesteal', 'Lifesteal Strike') #S4: Lifesteal Strike
        .replace('Lucent Strike', 'Lustrous Strike') #S2: Lustrous Strike
        .replace('Lucent Grace', 'Luminous Grace') #S3: Luminous Grace
        .replace('Swift Arrows', 'Swift Arrows Strike') #S4: Swift Arrows Strike
        .replace('Instant Guard Photons', 'Flashguard Lucent') #S4: Flashguard Lucent
        .replace('Impregnable Chain', 'Mighty Chain') #S4: Mighty Chain
        .replace('Prolonged Katana Release', 'Prolonged Blade') #S4: Prolonged Blade
        .replace('Photon Adaptation', 'Photon V Adaptation') #S4: Photon V Adaptation
        .replace('Photonic Trap', 'Lustrous Trap') #S4: Lustrous Trap
        .replace('Providential Refinement', 'Refined Providence') #S4: Refined Providence
        .replace('Guardian Gear', 'Guardian Shield') #S3: Guardian Shield
        .replace('Photon Reduction', 'Photon Descent') #S1: Photon Descent
        .replace('Superior Prowess', 'Skillful Adept') #S2: Skillful Adept
        .replace('Doom Break', 'Doom Break I')
    )
    return out

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

requests_cache.install_cache('cache')
try:
    os.mkdir('diff')
except FileExistsError:
    print('diff directory exists')
try:
    os.mkdir('old')
except FileExistsError:
    print('old directory exists')
try:
    os.mkdir('new')
except FileExistsError:
    print('new directory exists')
cwd = os.getcwd()

for weapon in weapons:
    print(f'Processing {weapon}')
    page = requests.get(f'https://pso2na.arks-visiphone.com/index.php?title={weapon}&action=edit')
    info = page.content.decode(encoding='utf-8')
    start = info.find('{{Weapon_Listing}}')
    end = info.find('{{Weapon_Listing}}', start + 1, -1)
    info = info[start:end+len('{{Weapon_Listing}}')]
    info = info.replace('&lt;', '<').replace('&amp;', '&')
    newpage = patch(info)
    print('Writing patch')
    with open(os.path.join(cwd, 'new', f'{weapon}.txt'), 'w', encoding='utf-8') as f:
        f.write(newpage)
    
    with open(os.path.join(cwd, 'old', f'{weapon}.txt'), 'w', encoding='utf-8') as old:
        old.write(info)

    diffText = difflib.ndiff(info.splitlines(keepends=True), newpage.splitlines(keepends=True))

    with open(os.path.join(cwd, 'diff', f'{weapon}.txt'), 'w', encoding='utf-8') as diff:
        diff.write(''.join(line for line in diffText if line.startswith('- ') or line.startswith('? ') or line.startswith('+ ')))