import requests
import pyodbc
import time


conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=<mySQLServerHere>;'
                      'Database=BoardGames;'
                      'Trusted_Connection=yes;')

cursor = conn.cursor()


r = requests.get('https://api.boardgameatlas.com/api/search?client_id=k6SmgnmCOB')


limit = r.json()["count"]


cursor.execute('''
    DELETE FROM [BoardGames].[dbo].[BoardGameTable]''')
conn.commit()


timerCount = 0
count = 0
while count < 1000:
    r = requests.get('https://api.boardgameatlas.com/api/search?client_id=k6SmgnmCOB'
                     + '&limit=100&skip=' + str(count))
    print(count)
    for game in r.json()["games"]:
        try:
            publisher = game["primary_publisher"]["name"]
        except:
            publisher = ' '

        cursor.execute('''
            
        
            INSERT INTO BoardGameTable (Name,CurrentPrice,MSRP,MinPlayers,MaxPlayers,Playtime,Publisher,YearPublished, 
                        ImageURL,Description)
            VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', game["name"], game["price"], game["msrp"], game["min_players"], game["max_players"],
            str(game["min_playtime"]) + '-' + str(game["max_playtime"]), str(publisher), game["year_published"],
            game["image_url"], str(game["description_preview"])[0:2000])
    count += 100
    # print(count)

    if r.status_code != 200:
        print('Did not receive a 200 status code.')
        break

    if timerCount < 5:
        timerCount += 1
    else:
        time.sleep(3)
        timerCount = 0

conn.commit()
