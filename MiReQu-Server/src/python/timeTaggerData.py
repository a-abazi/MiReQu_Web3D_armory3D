# numpy and math for statistical analysis
import numpy
import math

# PySide2 for the UI
from PySide2.QtWidgets import QApplication, QFileDialog
from PySide2.QtCore import QTimer

# generated file by: pyuic5 MiReQServerUI.ui > MiReQServerUI.py
# Please use the QtDesigner to edit the ui interface file
#from src.python.MiReQuServerUI import Ui_CoincidenceStream

from PyQt5 import QtWidgets

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger


class CoincidencesNoUI():

    def __init__(self,  tagger):

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
        #self.draw()
        #self.timer = QTimer()
        #self.timer.timeout.connect(self.draw)
        #self.timer.start(100)

    def startClicked(self):
        '''Handler for the start action button'''
        self.running = True

        if self.measurements_dirty:
            # If any configuration is changed while the measurements are stopped,
            # recreate them on the start button
            self.updateMeasurements()
        else:
            # else manually start them
            self.counter.start()
            self.correlation.start()

    def stopClicked(self):
        '''Handler for the stop action button'''
        self.running = False
        self.counter.stop()
        self.correlation.stop()

    def draw(self):
        if self.running:
            print(self.counter.getData()[0])
            #print(self.correlation.getData())
            self.measurements_dirty = False

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
                #binwidth=int(50e9), # in ps
                binwidth=int(100e9), # in ps
                #n_values=200
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




if __name__ == '__main__':
    import sys, os
    import PySide2

    dirname = os.path.dirname(PySide2.__file__)
    plugin_path = os.path.join(dirname, 'plugins', 'platforms')
    os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path

    app = QApplication(sys.argv)
    tagger = createTimeTagger()

    ccStream = CoincidenceStream(tagger)
    ccStream.show()

    app.exec_()

    freeTimeTagger(tagger)
