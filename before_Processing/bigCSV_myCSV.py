import csv # per usare i csv
import glob # per listare i file in una directory
import os

lista_emoji = []

def main () :
    folder_name = "csv/"
    mio_nick = "Marta"
    emojiFile_name = "emojis.txt"

    # mi salvo tutte le emoji caricandole dal file emoji.csv
    with open (emojiFile_name) as emojiFile:
        emojiReader = emojiFile.read()
        print emojiReader

        for emoji in emojiReader.split(','):
            lista_emoji.append(emoji)
        


    i = 1
    for csvFile_name in sorted(glob.glob(folder_name + "*.csv"), key=os.path.getsize):
        # creo una nuova cartella in cui mettere i nuovi file csv
        new_csvFile_name = "my_csv/" + str(i) + ".csv"
        i+=1
        print ("Apro il file " + csvFile_name)

        with open (csvFile_name) as csvFile:
            # apro il vecchio file in lettura
            csvReader = csv.DictReader (csvFile)

            with open (new_csvFile_name, 'w') as my_csvFile :
                # apro il nuovo file in scrittura
                fieldnames = ['date', 'message']
                csvWriter = csv.DictWriter (my_csvFile, fieldnames=fieldnames)
                csvWriter.writeheader()

                for row in csvReader:
                    # tengo solo i messaggi inviati da me e che non sono sticker
                    emoji_nel_testo = get_emojis_from_text(row['text'])
                    if (row['from'] == mio_nick and emoji_nel_testo != ""):
                        csvWriter.writerow({fieldnames[0]: row['date'], fieldnames[1]: emoji_nel_testo})
                        #print(row['from'] + ", " + row['to'] + ", " + row['date'] + ", " + row['text'])
        


def get_emojis_from_text (text) :
    da_restituire = ""

    for emoji in lista_emoji:
        for i in range (text.count(emoji)) :
            da_restituire += emoji + " "

    return da_restituire

if __name__ == "__main__":
    main()