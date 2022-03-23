import numpy as np
import matplotlib.pyplot as plt


data = np.loadtxt("20210319_zeitVerlauf.txt")

time = np.linspace(0,30,data.shape[1])

fig,axs = plt.subplots(2,1,figsize=(8,9), sharex=True)

axs[0].plot(time,data[0], ls='', marker =".",c = "red")
axs[0].plot(time,data[1], ls='', marker =".",c = "blue")
axs[0].plot(time,data[2], ls='', marker =".",c = "green")


axs[1].plot(time,data[0]/0.1,c = "red", label="Alice")
axs[1].plot(time,data[1]/0.1,c = "blue", label="Bob")
axs[1].plot(time,data[2]/0.1,c = "green", label="Beide")

axs[1].set_xlabel("Zeit (s)")
axs[1].set_ylabel("Zählrate (1/s)")
axs[0].set_ylabel("Zählereignisse pro Messinterval")

plt.legend()

#plt.show()
plt.savefig("zeitVerlauf_beispiel.png")

