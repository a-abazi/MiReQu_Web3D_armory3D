import matplotlib.pyplot as plt
import numpy as np

from datetime import datetime, timedelta

# Das mit den datentypen in numpy ist mir noch nicht gut gelungen
filename = "tstFile_Real.txt"
# hier lade ich die daten in strings
data = np.genfromtxt(filename, delimiter=";",dtype=[int,int,int,int,int,int,int,float,float,float,float,float,float,float,float,float,int,bool,bool,bool,int,int,int], unpack=True)
#data = np.array(data)


# die Richtungen des Eyetrackings müssen nochmal in floats umgewandelt werden. Ich verstehe nicht genau warum er es nicht oben schon macht aber das funktioniert so jedenfalls
dirX = np.array(data[7][:])
dirY = np.array(data[8][:])
dirZ = np.array(data[9][:])

#converting time strings to seconds
#hier nutze ich das datetime package um aus den Zeitdaten die differenz in sekunden zu erhalten
timeInSeconds = np.empty(dirX.shape)
initTime = datetime(year= data[0][0],
                    month=data[1][0],
                    day=data[2][0],
                    hour=data[3][0],
                    minute=data[4][0],
                    second=data[5][0],
                    microsecond=data[6][0]*1000,
                    )

for i in range(dirX.shape[0]):
    # hier sucht datetime aus den Strings die passenden daten
    time_i = datetime(year= data[0][i],
                    month=data[1][i],
                    day=data[2][i],
                    hour=data[3][i],
                    minute=data[4][i],
                    second=data[5][i],
                    microsecond=data[6][i]*1000,
                    )
    timeInSeconds[i] = (time_i - initTime ).total_seconds()


# hier plotte ich die Beispiel daten
plt.plot(timeInSeconds, dirX, label="x")
plt.plot(timeInSeconds, dirY, label="y")
plt.plot(timeInSeconds, dirZ, label="z")
plt.xlabel("Zeit in Sekunden")
plt.ylabel("Richtungswert")
plt.legend()
#plt.savefig("tstDatenReal.png")
plt.show()

