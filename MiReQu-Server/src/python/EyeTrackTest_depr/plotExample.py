import matplotlib.pyplot as plt
import numpy as np

from datetime import datetime, timedelta

# Das mit den datentypen in numpy ist mir noch nicht gut gelungen
filename = "tstFile_Real.txt"
# hier lade ich die daten in strings
data = np.genfromtxt(filename, delimiter=";", dtype=["U25",float,float,float,"U25",bool,bool], unpack=True)
data = np.array(data)

# die Richtungen des Eyetrackings müssen nochmal in floats umgewandelt werden. Ich verstehe nicht genau warum er es nicht oben schon macht aber das funktioniert so jedenfalls
dirX = np.array(data[1,:],float)
dirY = np.array(data[2,:],float)
dirZ = np.array(data[3,:],float)

#converting time strings to seconds
#hier nutze ich das datetime package um aus den Zeitdaten die differenz in sekunden zu erhalten
times = data[0,:]
timeInSeconds = []
for i in range(times.size):
    # hier sucht datetime aus den Strings die passenden daten
    timeInSeconds.append(datetime.strptime(times[i], "%d,%m,%Y,%H,%M,%S,%f",))

for i in range(times.size):
    if (i==0): continue
    #hier werden die Zeitintervalle in Sekunden berechnet
    timeInSeconds[i] = ((timeInSeconds[i] - timeInSeconds[0]).total_seconds() )
timeInSeconds[0] = 0


# hier plotte ich die Beispiel daten
plt.plot(timeInSeconds, dirX, label="x")
plt.plot(timeInSeconds, dirY, label="y")
plt.plot(timeInSeconds, dirZ, label="z")
plt.xlabel("Zeit in Sekunden")
plt.ylabel("Richtungswert")
plt.legend()
plt.savefig("tstDatenReal.png")
plt.show()

