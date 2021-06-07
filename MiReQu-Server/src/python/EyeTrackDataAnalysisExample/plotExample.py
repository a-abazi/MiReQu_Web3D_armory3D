import matplotlib.pyplot as plt
import numpy as np

from datetime import datetime, timedelta
from mpl_toolkits import mplot3d

filename = "tstFile_Real.txt"
data = np.genfromtxt(filename, delimiter=";",dtype=[int,int,int,int,int,int,int,float,float,float,float,float,float,float,float,float,int,bool,bool,bool,int,int,int], unpack=True)
#data = np.array(data)


dirX = np.array(data[7][:])
dirY = np.array(data[8][:])
dirZ = np.array(data[9][:])

indx_hauptversuch = np.where(data[-2] == 1)


targetX = np.array(data[12 + 1][indx_hauptversuch])
targetY = np.array(data[12 + 2][indx_hauptversuch])
targetZ = np.array(data[12 + 3][indx_hauptversuch])

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
#plt.plot(timeInSeconds, dirX, label="x")
#plt.plot(timeInSeconds, dirY, label="y")
#plt.plot(timeInSeconds, dirZ, label="z")
#plt.xlabel("Zeit in Sekunden")
#plt.ylabel("Richtungswert")
#plt.legend()
#plt.savefig("tstDatenReal.png")



ax = plt.axes(projection='3d')
ax.scatter3D(targetX,targetY,targetZ )
plt.show()

