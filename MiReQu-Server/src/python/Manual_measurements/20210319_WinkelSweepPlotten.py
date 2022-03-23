import numpy as np
import matplotlib.pyplot as plt

def load_Json(fileNameJsoN):
    import json
    json = json.load(open(fileNameJsoN,"r"))

    return json


if __name__ == '__main__':
    from scipy.optimize import curve_fit

    dataPM_asList = load_Json("20210319_PM_WinkelSweep.json")["data"]
    dataHV_asList = load_Json("20210319_HV_WinkelSweep.json")["data"]

    dataPM = np.array(dataPM_asList)[1:,:]
    dataHV = np.array(dataHV_asList)[1:,:]

    dataPM_plot = np.zeros((dataPM.shape[0]-1,2))
    dataHV_plot = np.zeros((dataHV.shape[0]-1,2))


    dataPM_plot[:, 0] = dataPM[1:, 1]
    dataHV_plot[:, 0] = dataHV[1:, 1]

    for i in range(dataPM.shape[0]-1):
        dataPM_plot[i, 1] = np.sum(dataPM[i+1,-1])/10

    for i in range(dataHV.shape[0] - 1):
        dataHV_plot[i, 1] = np.sum(dataHV[i + 1, -1])/10

    def fit_func(t,t0,A,b):
        t = np.deg2rad(t)
        t0 = np.deg2rad(t0)
        return np.cos(t-t0)**2*A+b

    x = np.linspace(0,180,200)

    poptPM, pcovPM = curve_fit(fit_func, dataPM_plot[:,0], dataPM_plot[:,1])
    poptHV, pcovHV = curve_fit(fit_func, dataHV_plot[:, 0], dataHV_plot[:, 1])


    plt.plot(dataPM_plot[:,0],dataPM_plot[:,1], marker = "x", ls ="",c="red", label = "Winkel Alice = 22.5, V = {:3.1f} %".format(100*(poptPM[1]-poptPM[2])/(poptPM[1]+poptPM[2])))
    plt.plot(x,fit_func(x,*poptPM),c="red")

    plt.plot(dataHV_plot[:,0],dataHV_plot[:,1], marker = "x", ls ="",c="green", label = "Winkel Alice = 0, V = {:3.1f} %".format(100*(poptHV[1]-poptHV[2])/(poptHV[1]+poptHV[2])))
    plt.plot(x, fit_func(x, *poptHV),c="green")

    plt.xlabel("Winkel Bob (deg)")
    plt.ylabel("Counts")

    plt.legend()

    #plt.show()
    plt.savefig("Winkelsweep_beispiel.png")


