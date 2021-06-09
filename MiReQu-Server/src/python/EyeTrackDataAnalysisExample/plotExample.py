import matplotlib.pyplot as plt
import numpy as np

from datetime import datetime, timedelta
from mpl_toolkits import mplot3d

filename = "TestEyeTrack_EyeTrackLog_0.txt"

time_data = np.genfromtxt(filename,delimiter=";", usecols=(0,1,2,3,4,5,6), dtype=int).transpose()
target_data = np.genfromtxt(filename,delimiter=";", usecols=(13,14,15)).transpose()
origin_data = np.genfromtxt(filename,delimiter=";", usecols=(10,11,12)).transpose()
exercise_data = np.genfromtxt(filename,delimiter=";", usecols=(21,22,23), dtype=int).transpose()

#indx_hauptVersuch = np.where(exercise_data[0] == 0 )


targetX = np.array(target_data[0])
targetY = np.array(target_data[1])
targetZ = np.array(target_data[2])

origin_dataX = np.array(origin_data[0])
origin_dataY = np.array(origin_data[1])
origin_dataZ = np.array(origin_data[2])

timeInSeconds = np.empty(targetX.shape)
initTime = datetime(year= time_data[0][0],
                    month=time_data[1][0],
                    day=time_data[2][0],
                    hour=time_data[3][0],
                    minute=time_data[4][0],
                    second=time_data[5][0],
                    microsecond=time_data[6][0]*1000,
                    )

for i in range(targetX.shape[0]):
    time_i = datetime(year= time_data[0][i],
                    month=time_data[1][i],
                    day=time_data[2][i],
                    hour=time_data[3][i],
                    minute=time_data[4][i],
                    second=time_data[5][i],
                    microsecond=time_data[6][i]*1000,
                    )
    timeInSeconds[i] = (time_i - initTime ).total_seconds()

#timeInSeconds = timeInSeconds[indx_hauptVersuch]
#
#targetX = targetX[indx_hauptVersuch]
#targetY = targetY[indx_hauptVersuch]
#targetZ = targetZ[indx_hauptVersuch]
#
#origin_dataX = origin_dataX[indx_hauptVersuch]
#origin_dataY = origin_dataY[indx_hauptVersuch]
#origin_dataZ = origin_dataZ[indx_hauptVersuch]

# hier plotte ich die Beispiel daten
#plt.plot(timeInSeconds, dirX, label="x")
#plt.plot(timeInSeconds, dirY, label="y")
#plt.plot(timeInSeconds, dirZ, label="z")
#plt.xlabel("Zeit in Sekunden")
#plt.ylabel("Richtungswert")
#plt.legend()
#plt.savefig("tstDatenReal.png")



ax = plt.axes(projection='3d')
ax.scatter3D(targetX,targetZ,targetY )
ax.scatter3D(origin_dataX,origin_dataZ,origin_dataY )
plt.show()

