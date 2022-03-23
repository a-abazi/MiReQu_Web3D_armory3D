import numpy as np
import matplotlib.pyplot as plt

def set_share_axes(axs, target=None, sharex=False, sharey=False):
    # source https://stackoverflow.com/questions/23528477/share-axes-in-matplotlib-for-only-part-of-the-subplots
    if target is None:
        target = axs.flat[0]
    # Manage share using grouper objects
    for ax in axs.flat:
        if sharex:
            target._shared_x_axes.join(target, ax)
        if sharey:
            target._shared_y_axes.join(target, ax)
    # Turn off x tick labels and offset text for all but the bottom row
    if sharex and axs.ndim > 1:
        for ax in axs[:-1,:].flat:
            ax.xaxis.set_tick_params(which='both', labelbottom=False, labeltop=False)
            ax.xaxis.offsetText.set_visible(False)
    # Turn off y tick labels and offset text for all but the left most column
    if sharey and axs.ndim > 1:
        for ax in axs[:,1:].flat:
            ax.yaxis.set_tick_params(which='both', labelleft=False, labelright=False)
            ax.yaxis.offsetText.set_visible(False)


data = np.loadtxt("20220222_PMBasisTwoDetectors.txt", delimiter=";")

# light on at 11:30 23.02.2022
time = data[:, 0]
time = time - time[0]

countsA = data[:, 1]
countsB = data[:, 3]
coincAB  = data[:, 5]

stdA  = data[:, 2]
stdB  = data[:, 4]
stdCC = data[:, 6]


# Switch between averages of 1 second (cleanPlot = False) and larger Bins for Averages defined by secondsForAvg (cleanPlot = True)

cleanPlot = True
#cleanPlot = False

# matplotlib std colors (array)
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']

# calculation average and standard deviation

secondsForAvg = 60 * 5

size_X = int(np.floor(time.shape[0]/secondsForAvg))
size_Y = secondsForAvg
difference = time.shape[0] - size_X * secondsForAvg


# Reshape arrays to easily take averages and standarddeviation, also for correct time
if (difference != 0):
    timeAvg = np.reshape(time[:-difference],(size_X,size_Y))[:,0]
    countsA_reshaped = np.reshape(countsA[:-difference],(size_X,size_Y))
    countsB_reshaped = np.reshape(countsB[:-difference],(size_X,size_Y))
    coincAB_reshaped = np.reshape(coincAB[:-difference],(size_X,size_Y))
    stdA_reshaped  = np.reshape(stdA [:-difference],(size_X,size_Y))
    stdB_reshaped  = np.reshape(stdB [:-difference],(size_X,size_Y))
    stdCC_reshaped = np.reshape(stdCC[:-difference],(size_X,size_Y))
else:
    timeAvg = np.reshape(time, (size_X, size_Y))[:, 0]
    countsA_reshaped = np.reshape(countsA, (size_X, size_Y))
    countsB_reshaped = np.reshape(countsB, (size_X, size_Y))
    coincAB_reshaped = np.reshape(coincAB, (size_X, size_Y))
    stdA_reshaped = np.reshape(stdA, (size_X, size_Y))
    stdB_reshaped = np.reshape(stdB, (size_X, size_Y))
    stdCC_reshaped = np.reshape(stdCC, (size_X, size_Y))


# take new Averages
countsA_Avg = np.average(countsA_reshaped, axis=1)
countsB_Avg = np.average(countsB_reshaped, axis=1)
coincAB_Avg = np.average(coincAB_reshaped, axis=1)

# take average of standard deviation and add standard deviation of averages
countsA_AvgStd =  np.sqrt( np.average(stdA_reshaped , axis=1)**2 + np.std(countsA_reshaped ,axis =1)**2)
countsB_AvgStd =  np.sqrt( np.average(stdB_reshaped , axis=1)**2 + np.std(countsB_reshaped ,axis =1)**2)
coincAB_AvgStd =  np.sqrt( np.average(stdCC_reshaped, axis=1)**2 + np.std(coincAB_reshaped ,axis =1)**2)


unitFactor = 1./1000.


timeAvg = timeAvg/(60*60)

if cleanPlot:

    fig, axs = plt.subplots(2, 1, figsize=(5, 6), sharex=True)


    axs[0].errorbar(timeAvg, countsA_Avg * unitFactor, yerr=countsA_AvgStd * unitFactor, ls='', errorevery=10,
                    marker=".", label="Alice",
                    elinewidth=1.2, markersize=3, )
    axs[0].errorbar(timeAvg, countsB_Avg * unitFactor, yerr=countsB_AvgStd * unitFactor, ls='', errorevery=10,
                    marker=".", label="Bob",
                    elinewidth=1, markersize=3, )
    axs[1].errorbar(timeAvg, coincAB_Avg * unitFactor, yerr=coincAB_AvgStd * unitFactor, ls='', errorevery=10,
                    marker=".", label="Both",
                    elinewidth=1, markersize=3, c=colors[2])


    axs[1].set_xlabel("Time (h)")
    axs[1].set_ylabel("Average Countrate Coincidences (kHz)")
    axs[0].set_ylabel("Average Countrate Singles (kHz)")


    axs[0].axvspan(17,18, color="grey",alpha = 0.5)
    axs[0].text(17.6,9300*unitFactor, "Turned on \nLight in the Room", ha="right")


    axs[0].legend()
    axs[1].legend()



    plt.tight_layout()
    plt.show()
    #plt.savefig("20220222_PMBasisTwoDetectors_CleanPlot.png")

else:
    fig, axs = plt.subplots(2, 2, figsize=(5*2, 6))

    set_share_axes(axs[:, 0], sharex=True)
    set_share_axes(axs[:, 1], sharex=True)

    set_share_axes(axs[1, :], sharey=True)
    set_share_axes(axs[0, :], sharey=True)

    axs[1, 0].set_xlabel("Time (s)")
    axs[1, 1].set_xlabel("Time (s)")

    axs[1, 0].set_ylabel("Average Countrate Coincidences (1/s)")
    axs[0, 0].set_ylabel("Average Countrate Singles (1/s)")


    lwLim = 17.15 * 3600.
    upLim = 17.3 * 3600.
    #zoomIdx = np.where(time < 18 * 3600)[0] and np.where(time > 17 * 3600)[0]
    zoomIdx = np.where( (upLim-lwLim)/2. > abs(time - (upLim+lwLim)/2.) )[0]


    axs[0, 0].errorbar(time, data[:, 1], yerr=data[:, 2], ls='', marker=".", label="Alice", errorevery=60, elinewidth=1,
                   markersize=1)
    axs[0, 0].errorbar(time, data[:, 3], yerr=data[:, 4], ls='', marker=".", label="Bob", errorevery=60, elinewidth=1,
                   markersize=1)
    axs[1, 0].errorbar(time, data[:, 5], yerr=data[:, 6], ls='', marker=".", label="Both", errorevery=60, elinewidth=1,
                    markersize=1, c =colors[2])

    axs[0, 0].legend()
    axs[1, 0].legend()

    axs[0, 1].errorbar(time[zoomIdx], data[zoomIdx, 1], yerr=data[zoomIdx, 2], ls='', marker=".", label="Alice", errorevery=20, elinewidth=1,
                   markersize=1)
    axs[0, 1].errorbar(time[zoomIdx], data[zoomIdx, 3], yerr=data[zoomIdx, 4], ls='', marker=".", label="Bob", errorevery=20, elinewidth=1,
                   markersize=1)
    axs[1, 1].errorbar(time[zoomIdx], data[zoomIdx, 5], yerr=data[zoomIdx, 6], ls='', marker=".", label="Both", errorevery=20, elinewidth=1,
                    markersize=1, c =colors[2])

    axs[0, 1].legend()
    axs[1, 1].legend()

    axs[0, 1].axvspan(lwLim, upLim, color="grey", alpha=0.5)
    axs[0, 0].axvspan(lwLim, upLim, color="grey", alpha=0.5)
    axs[1, 0].axvspan(lwLim, upLim, color="grey", alpha=0.5)
    axs[1, 1].axvspan(lwLim, upLim, color="grey", alpha=0.5)

    axs[0, 0].text(lwLim,12000, "Turned on \nLight in the Room", ha="right")

    axs[0, 0].set(xticklabels=[])
    axs[0, 1].set(xticklabels=[])

    axs[0, 1].set(yticklabels=[])
    axs[1, 1].set(yticklabels=[])

    plt.tight_layout()
    plt.show()
    #plt.savefig("20220222_PMBasisTwoDetectors_DetailedPlot.png")