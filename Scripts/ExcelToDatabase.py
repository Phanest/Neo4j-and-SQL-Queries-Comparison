import pandas as pd
import sqlite3
import numpy as np

class ExcelToDatabase:

    def __init__(self, srcFile, sheet, srcDatabase):
        self.data = self.beautify( pd.read_excel(srcFile, sheet_name=sheet, na_values=['', '—', '— ', '–']) )
        self.connection = sqlite3.connect(srcDatabase)

    def beautify(self, data):
        toRename = {}
        for key in data.keys():
            newKey = str.strip(key)
            toRename[key] = newKey
        data.rename(columns=toRename, inplace=True)

        #Remove whitespaces and quotes
        #Turns all 0 points to NULL
        data = data.applymap(lambda x: x.strip() if type(x) is str else x)
        data['Song'] = data['Song'].str.strip('\"')
        data.loc[:, 'Albania':'United Kingdom'] = data.loc[:, 'Albania':'United Kingdom'].replace(0, np.nan)
        data = data.fillna('None')

        return data

    def insertSQL(self, entity, data):
        db = self.connection
        count = len(data[0])

        command = 'INSERT INTO ' + entity + ' VALUES ('
        for i in range(0, count-1):
            command += '?,'
        command += '?)'

        for element in data:
            try:
                db.execute(command, element)
                db.commit()
            except: print(command, element)

    def export(self, name, sheet):
        writer = pd.ExcelWriter(name, engine='xlsxwriter')
        self.data.to_excel(writer, sheet)
        writer.save()

    def explode(self, attribute, sep=','):
        """
            If a column contains multiple values separated by a @sep, we can
            explode it into several new columns, we fill all the missing values
            with the string 'None' for convinience

            @attribute - attribute we want to explode
            @sep - by which we divide the values in the column
        """

        data = self.data
        newAttributes = set()
        for i in data.index:
            content = data.loc[i, attribute]
            content = content.split(sep)
            for j in range(0, len(content)):
                data.loc[i, attribute + str(j+1)] = content[j].strip()
                newAttributes.add(attribute + str(j+1))
        self.data = data.fillna('None')

        return newAttributes

    def createKey(self, nameOfIndex, *attributes):
        """
            Creates a key for our sql database. Is fed
            a list of @attributes and then finds all
            unique combinations of those attributes
            and assigns them a unique number. Then it
            adds the keys as a new column.

            @nameOfIndex - the name of the new column which holds the key
            @attributes* - a list of columns to be used to generate the unique key,
                input as separate variables ex. createKey(nameOfIndex, attribute1, attribute2...)
        """

        data = self.data
        attributes = list(attributes)
        data = data[attributes] #get only attributes we need
        keys = {}
        count = 0

        for i in data.index:
            values = tuple( data.iloc[[i]].values.tolist()[0] )
            if values not in keys.keys():
                keys[values] = count
                count += 1

            self.data.loc[i, nameOfIndex] = keys[values]

    def getAttributes(self, skipIfNan=False, *attributes):
        """
            Returns all pairs of values for the requested attributes.

            @skipIfNan - skips the row if it contains a missing value
            @attributes* - list of requested columns
        """

        data = self.data
        content = set()
        flag = 0

        for i in data.index:
            row = []
            for j, key in enumerate(attributes):
                if 'c:' in key: #if the key has the value in it, it is to be labeled as "c:value"
                    val = key.split(':')[1].strip()
                    row.append(val)
                else:
                    val = data[key][i]
                    if val == 'None':
                        if skipIfNan:
                            flag = 1
                            break
                        val = None
                    if key == 'Artist gender' and val is not None: val = val[0]
                    if key == 'Year' and val is not None: val = int(val)
                    row.append(val)
            if flag:
                flag = 0
                continue
            content.add( tuple(row) )

        content = list(content)

        return content

    def addYearFinale(self):
        """
            Distinguishes year and type of final (semi-final, final)
            and adds them to new columns
        """

        data = self.data
        for i in data.index:
            value = data.loc[i, 'Year']
            if type(value) != str:
                data.loc[i, 'type'] = 'f'
                data.loc[i, 'year'] = int(value)
            else:
                value = value.split(' ')
                data.loc[i, 'type'] = value[1].strip()
                data.loc[i, 'year'] = int(value[0])

    def InsertToDatabase(self):
        self.addYearFinale()

        self.importCountry()
        self.importArtist()
        self.importSong()
        self.importLanguages()
        self.importEurovision() #change if finale
        self.importFinale()
        self.importCompeted()
        self.importBets()
        self.importVote()

    def importCountry(self):
        data = self.getAttributes(False, 'Country', 'Region')
        self.insertSQL('Country', data)

    def importLanguages(self):
        categories = self.explode('Song language')
        data = None
        for category in categories:
            data = self.getAttributes(True, 'songid', category)
            self.insertSQL('Language', data)

    def importSong(self):
        self.createKey('songid', 'Song', 'Artist')
        data = self.getAttributes(False, 'songid', 'Song', 'English translation', 'artistid')
        self.insertSQL('Song', data)

    def importBets(self):
        data = self.getAttributes(True, 'Country', 'euroid', 'type', 'Approximate Betting Prices')
        self.insertSQL('Bets', data)

    def importArtist(self):
        self.createKey('artistid', 'Artist')
        data = self.getAttributes(False, 'artistid', 'Artist', 'Artist gender')
        self.insertSQL('Artist', data)

    def importCompeted(self):
        data = self.getAttributes(False, 'songid', 'euroid', 'Country')
        self.insertSQL('Competed', data)

    def importEurovision(self):
        self.createKey('euroid', 'Host Country', 'year')
        data = self.getAttributes(False, 'euroid', 'Host Country', 'year')
        self.insertSQL('Eurovision', data)

    def importFinale(self):
        data = self.getAttributes(False, 'euroid', 'type')
        self.insertSQL('Finale', data)

    def importVote(self):
        categories = self.data.loc[:, 'Albania':'United Kingdom'].keys()
        data = None
        for category in categories:
            data = self.getAttributes(True, 'c:' + category, 'Country', 'euroid', 'type', category)
            self.insertSQL('Vote', data)




src = '../Data/Eurovision.xls'
sheet = 'Final data by year'
srcDatabase = '../EuroSql2.sqlite3'

dstFile = '../Eurovision data.xlsx'