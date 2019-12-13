import re
import pandas as pd
import numpy as np

def ReadFile(src, sheet):
    data = pd.read_excel(src, sheet_name=sheet)
    return data

def MergeSimple(Entity, property, attribute):
    for i in data.index:
        val = data.loc[i, attribute]
        name = val.replace(' ', '')
        name = re.sub(r'[^\w]', '', name)

        if val == 'None':
            continue
        if type(val) == str:
            val = val.replace("'", "\\'")

        print("MERGE (:{} {{{}:'{}'}})".format(Entity, property, val))

def CreateSimple(Entity, property, attribute):
    for i in data.index:
        val = data.loc[i, attribute]
        name = val.replace(' ', '')
        name = re.sub(r'[^\w]', '', name)

        if val == 'None':
            continue
        print("CREATE ({}:{} {{{}:'{}'}})".format(name, Entity, property, val))

def formatNames(names, stitchName=''):
    a = ''
    for i in names:
        a += str(i)
    a += stitchName
    a = re.sub(r'[^\w]', '', a)
    a = a.replace(' ', '')
    return a

def Merge(Entity, attributes, properties, propertiesNames):
    namesData = data[attributes]
    valuesData = data[properties]

    for i in data.index:
        val = valuesData.iloc[i, :].values.tolist()
        name = formatNames(namesData.iloc[i, :].values.tolist())

        if name in Entities.keys():
            continue
        else:
            Entities[name] = 1

        cmd = "MERGE (:{} {{".format(Entity)
        for j in range(0, len(val)):
            value = val[j]
            if type(value) in types:
                cmd += "{}:{} ".format(propertiesNames[j], val[j])
            else:
                value = value.replace("'", "\\'")
                cmd += "{}:'{}' ".format(propertiesNames[j], val[j])
        cmd += "})"
        print(cmd)

def Create(Entity, attributes, properties, propertiesNames):
    namesData = data[attributes]
    valuesData = data[properties]

    for i in data.index:
        val = valuesData.iloc[i, :].values.tolist()
        name = formatNames(namesData.iloc[i, :].values.tolist())

        if name in Entities.keys():
            continue
        else:
            Entities[name] = 1

        cmd = "CREATE ({}:{} {{".format(name, Entity)
        for j in range(0, len(val)):
            cmd += "{}:'{}' ".format(propertiesNames[j], val[j].replace("'", "\\'"))
        cmd += "})"
        print(cmd)

def CreateNone(Entity, attributes, properties, propertiesNames, stitchName=''):
    namesData = data[attributes]
    valuesData = data[properties]

    for i in data.index:
        val = valuesData.iloc[i, :].values.tolist()
        name = formatNames(namesData.iloc[i, :].values.tolist(), stitchName)

        if 'None' in val:
            continue

        cmd = "CREATE ({}:{}:{} {{".format(name, Entity[0], Entity[1])
        for j in range(0, len(val)):
            cmd += "{}:'{}' ".format(propertiesNames[j], val[j].replace("'", "\\'"))
        cmd += "})"
        print(cmd)

def makeRelationship(Relationship, lAttributes, rAttributes):
    Left = data[lAttributes]
    Right = data[rAttributes]

    for i in data.index:
        lName = Left.iloc[i, :].values.tolist()
        rName = Right.iloc[i, :].values.tolist()

        lName = formatNames(lName)
        rName = formatNames(rName)

        if rName == 'None':
            continue

        cmd = "MERGE ({})-[:{}]->({})".format(lName, Relationship, rName)
        print(cmd)

def makeTranslationRelation(Relationship, lAttributes, rAttributes, Translation, stitchName):
    Left = data[lAttributes]
    Right = data[rAttributes]
    val = data[Translation]

    for i in data.index:
        lName = Left.iloc[i, :].values.tolist()
        rName = Right.iloc[i, :].values.tolist()
        value = val.iloc[i, :].values.tolist()

        if 'None' in value:
            continue

        lName = formatNames(lName)
        rName = formatNames(rName, stitchName)

        if rName == 'None':
            continue

        cmd = "MERGE ({})-[:{}]->({})".format(lName, Relationship, rName)
        print(cmd)

def addEurovisionsRelation():
    for i in range(1998, 2009):
        cmd = 'MATCH (prev:Eurovision {{year:{}}}),\n' \
              '(new:Eurovision {{year:{}}}),\n'.format(i, i+1) #todo ,

        print(cmd + 'MERGE (prev) -[:SUCCEDED_BY]-> (new)')
        print(cmd + 'MERGE (new) -[:PRECEDED_BY]-> (prev)')

def addVotes(countryFrom, attributes):
    countryTo = data[attributes]
    values = data[[countryFrom]]

    global pdf
    global j

    for i in data.index:
        toParticipant = countryTo.iloc[i, :].values.tolist()

        fromParticipant = toParticipant[:]
        del fromParticipant[0]
        fromParticipant.insert(0, countryFrom)

        points = values.iloc[i, :].values.tolist()[0]
        if points == 'None':
            continue

        pdf.loc[j] = [fromParticipant[0], fromParticipant[1], fromParticipant[2], points,
                    toParticipant[0]]
        j += 1

        cmd = "MERGE (:Participant {{country:'{}', year:'{}', type:'{}'}})-[:VOTED_FOR {{points:{}}}]->(:Participant {{country:'{}', year:'{}', type:'{}'}})"\
            .format(fromParticipant[0], fromParticipant[1], fromParticipant[2], points,
                    toParticipant[0], toParticipant[1], toParticipant[2])
        print(cmd)

def Participants(Entity, country, attributes):
    namesData = data[attributes]
    finaleData = data[['type', 'year', 'Host Country']]

    global pdf
    global j

    for i in data.index:
        names = namesData.iloc[i, :].values.tolist()
        finaleName = finaleData.iloc[i, :].values.tolist()
        val = namesData.iloc[i, :].values.tolist()

        if names[0] == 'None':
            continue

        del names[0]
        names.insert(0, country)
        name = formatNames(names)
        finaleName = formatNames(finaleName)

        if name in Entities.keys():
            continue
        else:
            Entities[name] = 1

        pdf.loc[j] = [country, val[1], val[2]]
        j += 1

        cmd = "MERGE (:{} {{country:'{}', year:{}, type:'{}' }})".format(Entity, country, val[1], val[2])
        print(cmd)

        cmd = "MERGE (:Country {{name:'{}'}})-[:PARTICIPATED_AS]->(:Participant {{country:'{}', year:{}, type:'{}'}})"\
            .format(country, country, val[1], val[2]) #todo Known entities but unknown relationship
        print(cmd)

        cmd = "MERGE (:{} {{country:'{}', year:{}, type:'{}'}})-[:PARTICIPATED_IN]->(:Finale {{type:'{}', year:{}}})"\
            .format(Entity, country, val[1], val[2], val[2], val[1]) #todo
        print(cmd)

    return pdf

src = '../Data/Eurovision data (Processed).xlsx'
sheet = 'Sheet 1'
types = [int, float, np.int64]

Entities = {}
data = ReadFile(src, sheet)

# MergeSimple('Country', 'name', 'Country')
# MergeSimple('Region', 'region', 'Region')
# MergeSimple('Artist', 'name', 'Artist')
# MergeSimple('Gender', 'gender', 'Artist gender')
#
# MergeSimple('Language', 'language', 'Song language1')
# MergeSimple('Language', 'language', 'Song language2')
# MergeSimple('Language', 'language', 'Song language3')
# MergeSimple('Language', 'language', 'Song language4')
#
# Merge('Eurovision', ['Host Country', 'year'], ['year'], ['year']) #:Eurovision {year:}
# Merge('Finale', ['type', 'year', 'Host Country'], ['type', 'year'], ['type', 'year']) #:Finale {type:, year:}
#
# Create('Song', ['Song', 'Artist'], ['Song'], ['name'])
# CreateNone(['Song', 'Translation'], ['Song', 'Artist'], ['English translation'], ['name'], 'English')
#
# Merge('Participant', ['Country', 'year', 'type'],
#       ['Approximate Betting Prices', 'Country', 'year', 'type'],
#       ['coefficient', 'country', 'year', 'type'])
#
# countries = data.loc[:, 'Albania':'United Kingdom'].keys()

pdf = pd.DataFrame(columns=['country_from', 'year', 'type', 'points', 'country_to'])
j = 0

# for country in countries:
#      Participants('Participant', country, [country, 'year', 'type'])
#
# makeRelationship('PARTICIPATED_AS', ['Country'], ['Country', 'year', 'type'] )
# makeRelationship('COMPETED_WITH', ['Country', 'year', 'type'], ['Song', 'Artist'] )
#
# makeRelationship('HOSTED_BY', ['Host Country', 'year'], ['Host Country'] )
# makeRelationship('HAD_FINALE', ['Host Country', 'year'], ['type', 'year', 'Host Country'] )
#
# makeRelationship('PART_OF', ['type', 'year', 'Host Country'], ['Host Country', 'year'] )
#
# languages = ['Song language1', 'Song language2', 'Song language3', 'Song language4']
# for language in languages:
#     makeRelationship('AVAILABLE_IN', ['Song', 'Artist'], [language])
#
# makeRelationship('MADE', ['Artist'], ['Song', 'Artist'] )
# makeRelationship('GENDER', ['Artist'], ['Artist gender'] )
#
# makeTranslationRelation('TRANSLATION', ['Song', 'Artist'], ['Song', 'Artist'], ['English translation'], 'English')
# addEurovisionsRelation()
#
countries = data.loc[:, 'Albania':'United Kingdom'].keys()
for country in countries:
     addVotes(country, ['Country', 'year', 'type'])
