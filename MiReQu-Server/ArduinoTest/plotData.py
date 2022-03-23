import numpy as np
import matplotlib.pyplot as plt


data = np.loadtxt("data03.txt")

plt.plot(data[:,0], data[:,0])
plt.plot(data[:,0], data[:,1])
plt.show()
print(max(data[:,1]))
print(min(data[:,1]))
print(sum(data[:,1])/len(data[:,1]))