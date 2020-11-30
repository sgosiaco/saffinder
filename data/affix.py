import demjson
import json
import requests
import requests_cache

class Affix:
    def __init__(self, name, effect):
        self.name = name
        self.effect = effect

requests_cache.install_cache('affix_cache')

page = requests.get('https://raw.githubusercontent.com/CorVous/PSO2AffixingAssistant/master/js/lang.js')

code = page.content.decode()
start = code.find('"AA01')
end = code.find('});') + 1
obj = '{\r\n\t'
obj += code[start: end]

objDict = demjson.decode(obj)
affixes = []
for obj in objDict.items():
    affixes.append(Affix(obj[1]['name_glen'], obj[1]['effect_glen']))

#jsonOut = json.dumps(objDict, ensure_ascii=False)
jsonOut = json.dumps([ob.__dict__ for ob in affixes])

f = open('affix.json', 'w', encoding='utf-8')
f.write(jsonOut)
f.close()