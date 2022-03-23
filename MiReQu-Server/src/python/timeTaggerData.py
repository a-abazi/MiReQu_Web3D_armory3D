# numpy and math for statistical analysis
import numpy
import math

# PySide2 for the UI
from PySide2.QtWidgets import QApplication, QFileDialog
from PySide2.QtCore import QTimer

# generated file by: pyuic5 MiReQServerUI.ui > MiReQServerUI.py
# Please use the QtDesigner to edit the ui interface file
# from src.python.MiReQuServerUI import Ui_CoincidenceStream

# from PyQt5 import QtWidgets

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger


class CoincidencesNoUI():

    def __init__(self, tagger):

        # Setup the Parameters
        self.defaultTimeTaggerParameters = {
            "channelA": 1,  # channel number
            "channelB": 2,  # channel number
            "delayA": 0,  # ps min= -99999 max = 99999 TODO: Implement Check in class
            "delayB": 0,  # ps
            "triggerA": .5,  # Voltage min=-2.5 max = 2.5 TODO: Implement Check in class
            "triggerB": .5,  # Voltage
            "testsignalA": False,
            "testsignalB": False,
            "coincidenceWindow": 4000,  # ps min=1 max=9999 TODO: Implement Check in class
            "correlationBinwidth": 40,  # ps min=1 max=9999 TODO: Implement Check in class
            "correlationBins": 1000,  # min=1 max=9999 TODO: Implement Check in class
        }

        self.channelA = self.defaultTimeTaggerParameters["channelA"]
        self.channelB = self.defaultTimeTaggerParameters["channelB"]
        self.delayA = self.defaultTimeTaggerParameters["delayA"]
        self.delayB = self.defaultTimeTaggerParameters["delayB"]
        self.triggerA = self.defaultTimeTaggerParameters["triggerA"]
        self.triggerB = self.defaultTimeTaggerParameters["triggerB"]
        self.testsignalA = self.defaultTimeTaggerParameters["testsignalA"]
        self.testsignalB = self.defaultTimeTaggerParameters["testsignalB"]
        self.coincidenceWindow = self.defaultTimeTaggerParameters["coincidenceWindow"]
        self.correlationBinwidth = self.defaultTimeTaggerParameters["correlationBinwidth"]
        self.correlationBins = self.defaultTimeTaggerParameters["correlationBins"]

        # Create the TimeTagger measurements
        self.running = True
        self.measurements_dirty = False
        self.tagger = tagger
        self.last_channels = [0, 0]
        self.last_coincidenceWindow = 0
        self.updateMeasurements()

        # Use a timer to redraw the plots every 100ms
        # self.draw()
        # self.timer = QTimer()
        # self.timer.timeout.connect(self.draw)
        # self.timer.start(100)

    def changeParameters(self, parameters):
        for key in self.defaultTimeTaggerParameters.keys():
            if key not in parameters:
                raise KeyError("Keys in new parameters dictionary are wrong/incomplete")

        self.channelA = parameters["channelA"]
        self.channelB = parameters["channelB"]
        self.delayA = parameters["delayA"]
        self.delayB = parameters["delayB"]
        self.triggerA = parameters["triggerA"]
        self.triggerB = parameters["triggerB"]
        self.testsignalA = parameters["testsignalA"]
        self.testsignalB = parameters["testsignalB"]
        self.coincidenceWindow = parameters["coincidenceWindow"]
        self.correlationBinwidth = parameters["correlationBinwidth"]
        self.correlationBins = parameters["correlationBins"]

        self.updateMeasurements()

    def updateMeasurements(self):
        '''Create/Update all TimeTagger measurement objects'''

        # If any configuration is changed while the measurements are stopped, recreate them on the start button
        if not self.running:
            self.measurements_dirty = True
            return

        # Set the input delay, trigger level, and test signal of both channels
        channels = [self.channelA, self.channelB]
        self.tagger.setInputDelay(channels[0], self.delayA)
        self.tagger.setInputDelay(channels[1], self.delayB)
        self.tagger.setTriggerLevel(channels[0], self.triggerA)
        self.tagger.setTriggerLevel(channels[1], self.triggerB)
        self.tagger.setTestSignal(channels[0], self.testsignalA)
        self.tagger.setTestSignal(channels[1], self.testsignalB)

        # Only recreate the counter if its parameter has changed,
        # else we'll clear the count trace too often
        coincidenceWindow = self.coincidenceWindow
        if self.last_channels != channels or self.last_coincidenceWindow != coincidenceWindow:
            self.last_channels = channels
            self.last_coincidenceWindow = coincidenceWindow

            # Create the virtual coincidence channel
            self.coincidences = Coincidences(
                self.tagger,
                [channels],
                coincidenceWindow
            )

            # Measure the count rate of both input channels and the coincidence channel
            # Use 200 * 50ms binning
            self.counter = Counter(
                self.tagger,
                channels + list(self.coincidences.getChannels()),
                # binwidth=int(50e9), # in ps
                binwidth=int(100e9),  # in ps
                # n_values=200
                n_values=100
            )

        # Wait with the correlation measurement until the settings above are applied
        self.tagger.sync()

        # Measure the correlation between A and B
        self.correlation = Correlation(
            self.tagger,
            channels[1],
            channels[0],
            self.correlationBinwidth,
            self.correlationBins
        )

        self.measurements_dirty = False

    def getCouterNormalizationFactor(self):
        bin_index = self.counter.getIndex()
        return 1e12 / bin_index[1] / 1e3  # normalize 'clicks / bin' to 'kclicks / second'


class QKDNoUI():

    def __init__(self, tagger):

        # Setup the Parameters
        self.defaultTimeTaggerParameters = {
            "channelA0": 1,  # channel number
            "channelA1": 2,  # channel number
            "channelB0": 3,  # channel number
            "channelB1": 4,  # channel number
            "delayA0": -5500,  # ps min= -99999 max = 99999 TODO: Implement Check in class
            "delayA1": -5500,  # ps min= -99999 max = 99999 TODO: Implement Check in class
            "delayB0": 0,  # ps
            "delayB1": 0,  # ps
            "triggerA0": .5,  # Voltage min=-2.5 max = 2.5 TODO: Implement Check in class
            "triggerA1": .5,  # Voltage min=-2.5 max = 2.5 TODO: Implement Check in class
            "triggerB0": .5,  # Voltage
            "triggerB1": .5,  # Voltage
            "testSignalA0": False,
            "testSignalA1": False,
            "testSignalB0": False,
            "testSignalB1": False,

            "coincidenceWindow": 4000,  # ps min=1 max=9999 TODO: Implement Check in class
        }

        self.channelA0 = self.defaultTimeTaggerParameters["channelA0"]
        self.channelA1 = self.defaultTimeTaggerParameters["channelA1"]
        self.channelB0 = self.defaultTimeTaggerParameters["channelB0"]
        self.channelB1 = self.defaultTimeTaggerParameters["channelB1"]
        self.delayA0 = self.defaultTimeTaggerParameters["delayA0"]
        self.delayA1 = self.defaultTimeTaggerParameters["delayA1"]
        self.delayB0 = self.defaultTimeTaggerParameters["delayB0"]
        self.delayB1 = self.defaultTimeTaggerParameters["delayB1"]
        self.triggerA0 = self.defaultTimeTaggerParameters["triggerA0"]
        self.triggerA1 = self.defaultTimeTaggerParameters["triggerA1"]
        self.triggerB0 = self.defaultTimeTaggerParameters["triggerB0"]
        self.triggerB1 = self.defaultTimeTaggerParameters["triggerB1"]
        self.testSignalA0 = self.defaultTimeTaggerParameters["testSignalA0"]
        self.testSignalA1 = self.defaultTimeTaggerParameters["testSignalA1"]
        self.testSignalB0 = self.defaultTimeTaggerParameters["testSignalB0"]
        self.testSignalB1 = self.defaultTimeTaggerParameters["testSignalB1"]

        self.coincidenceWindow = self.defaultTimeTaggerParameters["coincidenceWindow"]

        # Data for bins, not changeable during runtime, in current implementation
        #self.binwidth = int(50e9)
        self.binwidth = int(100e9) #in pico seconds
        #self.n_values = 200
        self.n_values = 100

        # Create the TimeTagger measurements
        self.running = True
        self.measurements_dirty = False
        self.tagger = tagger
        self.last_channels = [0, 0, 0, 0]
        self.last_coincidenceWindow = 0
        self.updateMeasurements()

    def changeParameters(self, parameters):
        for key in self.defaultTimeTaggerParameters.keys():
            if key not in parameters:
                raise KeyError("Keys in new parameters dictionary are wrong/incomplete")

        self.channelA0 = parameters["channelA0"]
        self.channelA1 = parameters["channelA1"]
        self.channelB0 = parameters["channelB0"]
        self.channelB1 = parameters["channelB1"]
        self.delayA0 = parameters["delayA0"]
        self.delayA1 = parameters["delayA1"]
        self.delayB0 = parameters["delayB0"]
        self.delayB1 = parameters["delayB1"]
        self.triggerA0 = parameters["triggerA0"]
        self.triggerA1 = parameters["triggerA1"]
        self.triggerB0 = parameters["triggerB0"]
        self.triggerB1 = parameters["triggerB1"]
        self.testSignalA0 = parameters["testSignalA0"]
        self.testSignalA1 = parameters["testSignalA1"]
        self.testSignalB0 = parameters["testSignalB0"]
        self.testSignalB1 = parameters["testSignalB1"]

        self.coincidenceWindow = parameters["coincidenceWindow"]

        self.updateMeasurements()

    def updateMeasurements(self):
        """Create/Update all TimeTagger measurement objects"""

        # If any configuration is changed while the measurements are stopped, recreate them on the start button
        if not self.running:
            self.measurements_dirty = True
            return

        # Set the input delay, trigger level, and test signal of both channels
        channels = [self.channelA0, self.channelA1, self.channelB0, self.channelB1]
        self.tagger.setInputDelay(channels[0], self.delayA0)
        self.tagger.setInputDelay(channels[1], self.delayA1)
        self.tagger.setInputDelay(channels[2], self.delayB0)
        self.tagger.setInputDelay(channels[3], self.delayB1)

        self.tagger.setTriggerLevel(channels[0], self.triggerA0)
        self.tagger.setTriggerLevel(channels[1], self.triggerA1)
        self.tagger.setTriggerLevel(channels[2], self.triggerB0)
        self.tagger.setTriggerLevel(channels[3], self.triggerB1)

        self.tagger.setTestSignal(channels[0], self.testSignalA0)
        self.tagger.setTestSignal(channels[1], self.testSignalA1)
        self.tagger.setTestSignal(channels[2], self.testSignalB0)
        self.tagger.setTestSignal(channels[3], self.testSignalB1)

        # Only recreate the counter if its parameter has changed,
        # else we'll clear the count trace too often
        coincidenceWindow = self.coincidenceWindow
        if self.last_channels != channels or self.last_coincidenceWindow != coincidenceWindow:
            self.last_channels = channels
            self.last_coincidenceWindow = coincidenceWindow

            # Create the virtual coincidence channel
            self.coincidences = Coincidences(
                self.tagger,
                [
                    [channels[0], channels[2]],
                    [channels[0], channels[3]],
                    [channels[1], channels[2]],
                    [channels[1], channels[3]],

                ],
                coincidenceWindow
            )
            # Measure the count rate of both input channels and the coincidence channel
            # Use 200 * 50ms binning
            self.counterSingles = Counter(
                self.tagger,
                channels,  # + list(self.coincidences.getChannels()),
                binwidth=self.binwidth,
                n_values=self.n_values
            )

            self.counterCoincidences = Counter(
                self.tagger,
                list(self.coincidences.getChannels()),
                binwidth=self.binwidth,
                n_values=self.n_values
            )

        # Wait with the correlation measurement until the settings above are applied
        self.tagger.sync()

        self.measurements_dirty = False

    def getCounterNormalizationFactor(self):
        bin_index = self.counterSingles.getIndex()
        return 1e12 / bin_index[1] / 1e3  # normalize 'clicks / bin' to 'kclicks / second'


if __name__ == '__main__':
    import time
    import numpy as np

    tagger = createTimeTagger()
    #ccStream = CoincidencesNoUI(tagger)
    ccStream = QKDNoUI(tagger)
    print(ccStream.getCounterNormalizationFactor())

    time.sleep(10.1)
    # np.savetxt("20210319_zeitVerlauf.txt",ccStream.counter.getData())
    print(ccStream.counterSingles.getData()*ccStream.getCounterNormalizationFactor())
    print(ccStream.counterCoincidences.getData()*ccStream.getCounterNormalizationFactor())

    freeTimeTagger(tagger)
