import os
import sys

from PyQt5.QtWidgets import QMainWindow, QApplication, QFileDialog
from PyQt5.QtCore import QTimer
from PyQt5 import uic


# matplotlib for the plots, including its Qt backend
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg, NavigationToolbar2QT
from matplotlib.figure import Figure

# numpy for statistical analysis
import numpy as np

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger


class MonitorGUI(QMainWindow):
    ''' Small example of how to create a UI for the TimeTagger with the PySide2/PyQt5 framework'''

    def __init__(self, tagger):
        '''Constructor of the coincidence example window
        The TimeTagger object must be given as arguments to support running many windows at once.'''

        # Create the UI from the designer file and connect its action buttons
        super(MonitorGUI, self).__init__()

        modus = 1 # switch this number between 1 and 2 to switch modi of the GUI

        if modus == 1:
            self.SecondPlot_Zoom = False
            self.showCorrelations = True

        elif modus == 2:
            self.SecondPlot_Zoom = True
            self.showCorrelations = False
        else:
            self.SecondPlot_Zoom = False
            self.showCorrelations = True


        self.movingAverageWindow = int(20)
        self.singlesMaxValues = [0,0,0,0]


        # Please use the QtDesigner to edit the ui interface file
        my_dir = os.path.dirname(__file__)
        self.ui = uic.loadUi(os.path.join(my_dir, 'MonitorGUIWindow.ui'), self)
        self.ui.startButton.clicked.connect(self.startClicked)
        self.ui.stopButton.clicked.connect(self.stopClicked)
        self.ui.clearButton.clicked.connect(self.clearClicked)
        self.ui.saveButton.clicked.connect(self.saveClicked)

        # Update the measurements whenever any input configuration changes
        self.ui.channelA0.valueChanged.connect(self.updateMeasurements)
        self.ui.channelA1.valueChanged.connect(self.updateMeasurements)
        self.ui.channelB0.valueChanged.connect(self.updateMeasurements)
        self.ui.channelB1.valueChanged.connect(self.updateMeasurements)


        ### Set some default parameters
        self.ui.delayA0.setValue(-5500)
        self.ui.delayA1.setValue(-5500)
        self.ui.coincidenceWindow.setValue(4000)

        self.ui.delayA0.valueChanged.connect(
            lambda value: self.setInputDelay('A0', value)
        )
        self.ui.delayA1.valueChanged.connect(
            lambda value: self.setInputDelay('A1', value)
        )
        self.ui.delayB0.valueChanged.connect(
            lambda value: self.setInputDelay('B0', value)
        )
        self.ui.delayB1.valueChanged.connect(
            lambda value: self.setInputDelay('B1', value)
        )
        self.ui.triggerA0.valueChanged.connect(
            lambda value: self.setTriggerLevel('A0', value)
        )
        self.ui.triggerA1.valueChanged.connect(
            lambda value: self.setTriggerLevel('A1', value)
        )
        self.ui.triggerB0.valueChanged.connect(
            lambda value: self.setTriggerLevel('B0', value)
        )
        self.ui.triggerB1.valueChanged.connect(
            lambda value: self.setTriggerLevel('B1', value)
        )

        self.ui.corrSinglesChannel1.currentIndexChanged.connect(self.updateMeasurements)
        self.ui.corrSinglesChannel2.currentIndexChanged.connect(self.updateMeasurements)
        self.ui.corrCoincChannel1.currentIndexChanged.connect(self.updateMeasurements)
        self.ui.corrCoincChannel2.currentIndexChanged.connect(self.updateMeasurements)

        self.ui.testsignalA0.stateChanged.connect(self.updateMeasurements)
        self.ui.testsignalA1.stateChanged.connect(self.updateMeasurements)
        self.ui.testsignalB0.stateChanged.connect(self.updateMeasurements)
        self.ui.testsignalB1.stateChanged.connect(self.updateMeasurements)

        self.ui.coincidenceWindow.valueChanged.connect(self.updateMeasurements)
        self.ui.correlationBinwidth.valueChanged.connect(self.updateMeasurements)
        self.ui.correlationBins.valueChanged.connect(self.updateMeasurements)

        # Create the matplotlib figure with its subplots for the counter and correlation
        if self.showCorrelations:
            self.fig = Figure()
            self.counterSinglesAxis = self.fig.add_subplot(221)
            self.counterCoincidencesAxis = self.fig.add_subplot(222)
            self.correlationSinglesAxis = self.fig.add_subplot(223)
            self.correlationCoincidencesAxis = self.fig.add_subplot(224)
        else:
            self.fig = Figure()
            if self.SecondPlot_Zoom:
                self.counterSinglesAxis = self.fig.add_subplot(131)
                self.counterSinglesAxisZoom = self.fig.add_subplot(132)
                self.counterCoincidencesAxis = self.fig.add_subplot(133)
            else:
                self.counterSinglesAxis = self.fig.add_subplot(121)
                self.counterCoincidencesAxis = self.fig.add_subplot(122)


            self.figEmpty = Figure()
            self.correlationSinglesAxis = self.figEmpty.add_subplot(223)
            self.correlationCoincidencesAxis = self.figEmpty.add_subplot(224)

        self.canvas = FigureCanvasQTAgg(self.fig)
        self.toolbar = NavigationToolbar2QT(self.canvas, self)
        self.ui.plotWidget.layout().addWidget(self.toolbar)
        self.ui.plotWidget.layout().addWidget(self.canvas)

        # Create the TimeTagger measurements
        self.running = True
        self.measurements_dirty = False
        self.tagger = tagger
        self.last_channels = [0, 0, 0, 0]
        self.last_coincidenceWindow = 0
        self.updateMeasurements()

        #

        # Use a timer to redraw the plots every 100ms
        self.timer = QTimer(interval=100, timeout=self.updateCounterPlot)
        self.timer.start()

    def moving_average(self, x, w):
        return np.convolve(x, np.ones(w), 'valid') / w

    def getCouterNormalizationFactor(self):
        bin_index = self.counterSingles.getIndex()
        # normalize 'clicks / bin' to 'kclicks / second'
        return 1e12 / bin_index[1] / 1e3

    def updateMeasurements(self):
        '''Create/Update all TimeTagger measurement objects'''

        # If any configuration is changed while the measurements are stopped, recreate them on the start button
        if not self.running:
            self.measurements_dirty = True
            return

        # Set the input delay, trigger level, and test signal of both channels
        channels = [self.ui.channelA0.value(), self.ui.channelA1.value(),
                    self.ui.channelB0.value(), self.ui.channelB1.value()]

        self.tagger.setInputDelay(channels[0], self.ui.delayA0.value())
        self.tagger.setInputDelay(channels[1], self.ui.delayA1.value())
        self.tagger.setInputDelay(channels[2], self.ui.delayB0.value())
        self.tagger.setInputDelay(channels[3], self.ui.delayB1.value())

        self.tagger.setTriggerLevel(channels[0], self.ui.triggerA0.value())
        self.tagger.setTriggerLevel(channels[1], self.ui.triggerA1.value())
        self.tagger.setTriggerLevel(channels[2], self.ui.triggerB0.value())
        self.tagger.setTriggerLevel(channels[3], self.ui.triggerB1.value())

        self.tagger.setTestSignal(channels[0], self.ui.testsignalA0.isChecked())
        self.tagger.setTestSignal(channels[1], self.ui.testsignalA1.isChecked())
        self.tagger.setTestSignal(channels[2], self.ui.testsignalB0.isChecked())
        self.tagger.setTestSignal(channels[3], self.ui.testsignalB1.isChecked())

        # Only recreate the counter if its parameter has changed,
        # else we'll clear the count trace too often
        coincidenceWindow = self.ui.coincidenceWindow.value()
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
                channels,#+ list(self.coincidences.getChannels()),
                binwidth=int(50e9),
                n_values=200
            )

            self.counterCoincidences = Counter(
                self.tagger,
                list(self.coincidences.getChannels()),
                binwidth=int(50e9),
                n_values=200
            )


        # Measure the correlation between A and B
        self.correlationSingles = Correlation(
            self.tagger,
            channels[self.ui.corrSinglesChannel1.currentIndex()],
            channels[self.ui.corrSinglesChannel2.currentIndex()],
            self.ui.correlationBinwidth.value(),
            self.ui.correlationBins.value()
        )

        self.correlationCoincidences = Correlation(
            self.tagger,
            list(self.coincidences.getChannels())[self.ui.corrCoincChannel1.currentIndex()],
            list(self.coincidences.getChannels())[self.ui.corrCoincChannel2.currentIndex()],
            self.ui.correlationBinwidth.value(),
            self.ui.correlationBins.value()
        )

        # Create the measurement plots
        self.counterSinglesAxis.clear()
        self.counterSinglesAxis.set_prop_cycle(color=['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'])
        self.plt_counterSingles = self.counterSinglesAxis.plot(
            self.counterSingles.getIndex() * 1e-12,
            self.counterSingles.getData().T * self.getCouterNormalizationFactor()
            ,marker=".", linestyle="", markersize=3,
        )


        self.plt_counterSinglesMovingAverage = self.counterSinglesAxis.plot(
            (self.counterSingles.getIndex() * 1e-12)[:-self.movingAverageWindow+1],
            (self.counterSingles.getData().T * self.getCouterNormalizationFactor())[:-self.movingAverageWindow+1],
            linestyle="-", linewidth=3
        )

        if self.SecondPlot_Zoom:
            self.counterSinglesAxisZoom.clear()
            self.counterSinglesAxisZoom.set_prop_cycle(color=['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'])
            self.plt_counterSinglesZoom = self.counterSinglesAxisZoom.plot(
                self.counterSingles.getIndex() * 1e-12,
                self.counterSingles.getData().T * self.getCouterNormalizationFactor()
                , marker=".", linestyle="", markersize=3,
            )

            self.plt_counterSinglesMovingAverageZoom = self.counterSinglesAxisZoom.plot(
                (self.counterSingles.getIndex() * 1e-12)[:-self.movingAverageWindow + 1],
                (self.counterSingles.getData().T * self.getCouterNormalizationFactor())[:-self.movingAverageWindow + 1],
                linestyle="-", linewidth=3
            )



        """
        self.plt_singlesMax = self.counterSinglesAxis.plot(
            [0,10], [0, 0], linestyle="-", linewidth=3

        )
        """

        self.counterSinglesAxis.set_xlabel('time (s)')
        self.counterSinglesAxis.set_ylabel('count rate (kEvents/s)')
        self.counterSinglesAxis.set_title('Count rate')
        self.counterSinglesAxis.legend(['A0', 'A1', 'B0', 'B1', ])
        self.counterSinglesAxis.grid(True)

        if self.SecondPlot_Zoom:
            self.counterSinglesAxisZoom.set_xlabel('time (s)')
            self.counterSinglesAxisZoom.set_ylabel('count rate (kEvents/s)')
            self.counterSinglesAxisZoom.set_title('Count rate')
            self.counterSinglesAxisZoom.legend(['A0', 'A1', 'B0', 'B1', ])
            self.counterSinglesAxisZoom.grid(True)

        self.counterCoincidencesAxis.clear()
        self.counterCoincidencesAxis.set_prop_cycle(color=['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'])
        self.plt_counterCoincidences = self.counterCoincidencesAxis.plot(
            self.counterCoincidences.getIndex() * 1e-12,
            self.counterCoincidences.getData().T * self.getCouterNormalizationFactor()
            , marker=".", linestyle="", markersize=3,
        )
        self.plt_counterCoincidencesMovingAverage = self.counterCoincidencesAxis.plot(
            (self.counterCoincidences.getIndex() * 1e-12)[:-self.movingAverageWindow+1],
            (self.counterCoincidences.getData().T * self.getCouterNormalizationFactor())[:-self.movingAverageWindow+1],
            linestyle="-", linewidth=3
        )


        self.counterCoincidencesAxis.set_xlabel('time (s)')
        self.counterCoincidencesAxis.set_ylabel('count rate (kEvents/s)')
        self.counterCoincidencesAxis.set_title('Coincidences rate')
        self.counterCoincidencesAxis.legend(['A0B0', 'A0B1', 'A1B0', 'A1B1', ])
        self.counterCoincidencesAxis.grid(True)

        ###################
        self.correlationSinglesAxis.clear()
        index = self.correlationSingles.getIndex()
        data = self.correlationSingles.getDataNormalized()
        self.plt_correlation = self.correlationSinglesAxis.plot(
            index * 1e-3,
            data
            , marker=".", linestyle=""
        )
        self.plt_gauss = self.correlationSinglesAxis.plot(
            index * 1e-3,
            data,
            linestyle='--'
        )
        self.correlationSinglesAxis.axvspan(
            -coincidenceWindow/1000.,
            coincidenceWindow/1000.,
            color='green',
            alpha=0.3
        )
        self.correlationSinglesAxis.set_xlabel('time (ns)')
        self.correlationSinglesAxis.set_ylabel('normalized correlation')
        self.correlationSinglesAxis.set_title('Correlation Sinlges')
        self.correlationSinglesAxis.grid(True)
        ###################
        self.correlationCoincidencesAxis.clear()
        indexCC = self.correlationCoincidences.getIndex()
        dataCC = self.correlationCoincidences.getDataNormalized()
        #dataCC = self.correlationCoincidences.getData()
        self.plt_correlationCoincidences = self.correlationCoincidencesAxis.plot(
            indexCC * 1e-3,
            dataCC,
            marker=".", linestyle=""
        )
        self.correlationCoincidencesAxis.set_xlabel('time (ns)')
        self.correlationCoincidencesAxis.set_ylabel('normalized correlation')
        self.correlationCoincidencesAxis.set_title('Correlation Coincidences')
        self.correlationCoincidencesAxis.grid(True)
        ###################


        # Generate nicer plots
        self.fig.tight_layout()

        self.measurements_dirty = False

        # Update the plot with real numbers
        self.updateCounterPlot()

    def getTaggerChannel(self, label):
        """Resolve channel label into the Time Tagger channel number"""
        assert label in 'A0A1B0B1', 'Unknown channel label "{}"'.format(label)
        return int(getattr(self.ui, 'channel{}'.format(label)).value())

    def setInputDelay(self, channel, value):
        """Set input delay on channel A or B"""
        tt_channel = self.getTaggerChannel(channel)
        self.tagger.setInputDelay(tt_channel, value)

    def setTestSignal(self, channel, enable):
        """Enable/Disable test signal on the channel A or B"""
        tt_channel = self.getTaggerChannel(channel)
        self.tagger.setTestSignal(tt_channel, enable)

    def setTriggerLevel(self, channel, value):
        """Set trigger level on channel A or B"""
        tt_channel = self.getTaggerChannel(channel)
        self.tagger.setTriggerLevel(tt_channel, value)

    def startClicked(self):
        '''Handler for the start action button'''
        self.running = True

        if self.measurements_dirty:
            # If any configuration is changed while the measurements are stopped,
            # recreate them on the start button
            self.updateMeasurements()
        else:
            # else manually start them
            self.counterSingles.start()
            self.counterCoincidences.start()
            self.correlationSingles.start()
            self.correlationCoincidences.start()

    def stopClicked(self):
        '''Handler for the stop action button'''
        self.running = False
        self.counterSingles.stop()
        self.counterCoincidences.stop()
        self.correlationSingles.stop()
        self.correlationCoincidences.stop()

    def clearClicked(self):
        '''Handler for the clear action button'''
        self.correlationSingles.clear()
        self.correlationCoincidences.clear()

    def saveClicked(self):         ### TODO: Anpassen für neue Version
        '''Handler for the save action button'''


        # Ask for a filename
        filename, _ = QFileDialog().getSaveFileName(
            parent=self,
            caption='Save to File',
            directory='MonitorGUIData.txt',  # default name
            filter='All Files (*);;Text Files (*.txt)',
            options=QFileDialog.DontUseNativeDialog
        )

        # And write all results to disk
        if filename:
            with open(filename, 'w') as f:
                f.write("%"+'Input channel A: %d\n' % self.ui.channelA0.value())
                f.write("%"+'Input channel A: %d\n' % self.ui.channelA1.value())
                f.write("%"+'Input channel B: %d\n' % self.ui.channelB0.value())
                f.write("%"+'Input channel B: %d\n' % self.ui.channelB1.value())
                f.write("%"+'Input delay A: %d ps\n' % self.ui.delayA0.value())
                f.write("%"+'Input delay A: %d ps\n' % self.ui.delayA1.value())
                f.write("%"+'Input delay B: %d ps\n' % self.ui.delayB0.value())
                f.write("%"+'Input delay B: %d ps\n' % self.ui.delayB1.value())
                f.write("%"+'Trigger level A: %.3f V\n' % self.ui.triggerA0.value())
                f.write("%"+'Trigger level A: %.3f V\n' % self.ui.triggerA1.value())
                f.write("%"+'Trigger level B: %.3f V\n' % self.ui.triggerB0.value())
                f.write("%"+'Trigger level B: %.3f V\n' % self.ui.triggerB1.value())
                f.write("%"+'Coincidence window: %d ps\n' % self.ui.coincidenceWindow.value())
                f.write("%"+'Correlation bin width: %d ps\n' % self.ui.correlationBinwidth.value())
                f.write("%"+'Correlation bins: %d\n\n' % self.ui.correlationBins.value())

                f.write('Counter data:\n%s\n\n' % self.counterSingles.getData().__repr__())
                f.write('Correlation data:\n%s\n\n' % self.correlationSingles.getData().__repr__())

    def resizeEvent(self, event):
        '''Handler for the resize events to update the plots'''
        self.fig.tight_layout()
        self.canvas.draw()

    def updateCounterPlot(self):
        '''Handler for the timer event to update the plots'''
        if self.running:
            # Counter
            data = self.counterSingles.getData() * self.getCouterNormalizationFactor()
            idx = 0

            if self.SecondPlot_Zoom:
                for data_line, plt_counterSingles, plt_counterSinglesZoom, plt_counterSinglesAVG, plt_counterSinglesAVGZoom in zip(data,
                                                                                                        self.plt_counterSingles,
                                                                                                        self.plt_counterSinglesZoom,
                                                                                                        self.plt_counterSinglesMovingAverage,
                                                                                                        self.plt_counterSinglesMovingAverageZoom):
                    plt_counterSingles.set_ydata(data_line)
                    plt_counterSinglesZoom.set_ydata(data_line)
                    plt_counterSinglesAVG.set_ydata(self.moving_average(data_line, self.movingAverageWindow))
                    plt_counterSinglesAVGZoom.set_ydata(self.moving_average(data_line, self.movingAverageWindow))

                self.counterSinglesAxis.relim()
                self.counterSinglesAxis.autoscale_view(True, True, True)
                self.counterSinglesAxisZoom.relim()
                self.counterSinglesAxisZoom.autoscale_view(True, True, True)

            else:
                # for data_line, plt_counterSingles, plt_counterSinglesAVG, plt_sMax in zip(data, self.plt_counterSingles, self.plt_counterSinglesMovingAverage, self.plt_singlesMax):

                for data_line, plt_counterSingles, plt_counterSinglesAVG in zip(data, self.plt_counterSingles,
                                                                                self.plt_counterSinglesMovingAverage):
                    plt_counterSingles.set_ydata(data_line)
                    plt_counterSinglesAVG.set_ydata(self.moving_average(data_line, self.movingAverageWindow))
                    """
                    if (self.singlesMaxValues[idx]<data_line[-1]):
                        self.singlesMaxValues[idx] = data_line[-1]
                        plt_sMax.set_ydata([self.singlesMaxValues[idx],self.singlesMaxValues[idx]])
                    idx+=                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               1
                    """
                self.counterSinglesAxis.relim()
                self.counterSinglesAxis.autoscale_view(True, True, True)

            dataCC = self.counterCoincidences.getData() * self.getCouterNormalizationFactor()
            for data_line, plt_counterCoincidences, plt_counterCoincidencesAVG in zip(dataCC, self.plt_counterCoincidences, self.plt_counterCoincidencesMovingAverage):
                plt_counterCoincidences.set_ydata(data_line)
                plt_counterCoincidencesAVG.set_ydata(self.moving_average(data_line, self.movingAverageWindow))
            self.counterCoincidencesAxis.relim()
            self.counterCoincidencesAxis.autoscale_view(True, True, True)


            
            # Calculate the expectation and the standard deviation of the correlation
            # With this two values, we can display a Gaussian fit
            index = self.correlationSingles.getIndex()
            data = self.correlationSingles.getDataNormalized()
            total = np.sum(data)
            if total > 0:
                offset = np.sum(data * index) / total
                stddev = np.sqrt(np.sum(data * (index - offset)**2) / total)
            else:
                offset = 0
                stddev = 0
            if stddev > 0:
                corr_binwidth = self.ui.correlationBinwidth.value()
                A = corr_binwidth * total / np.sqrt(2*np.pi*stddev**2)
                gauss = A * np.exp(- 0.5 * (index - offset)**2 / stddev**2)
            else:
                gauss = index * 0

            # Correlation

            self.plt_correlation[0].set_ydata(
                self.correlationSingles.getDataNormalized())
            self.plt_gauss[0].set_ydata(gauss)
            
            self.correlationSinglesAxis.relim()
            self.correlationSinglesAxis.autoscale_view(True, True, True)
            self.correlationSinglesAxis.legend(['measured correlation', '$\mu$=%.1fps, $\sigma$=%.1fps' % (
                offset, stddev), 'coincidence window'])
            #################################

            # Correlation


            data = self.correlationCoincidences.getDataNormalized()
            total = np.sum(data)
            if total>0:
                self.plt_correlationCoincidences[0].set_ydata(
                    self.correlationCoincidences.getDataNormalized())

                self.correlationCoincidencesAxis.relim()
                self.correlationCoincidencesAxis.autoscale_view(True, True, True)


            self.canvas.draw()


# If this file is executed, initialize QApplication, create a TimeTagger object, and show the UI
if __name__ == '__main__':
    app = QApplication(sys.argv)

    tagger = createTimeTagger()

    # If you want to include this window within a bigger UI,
    # just copy these two lines within any of your handlers.
    window = MonitorGUI(tagger)
    window.show()

    app.exec_()

    freeTimeTagger(tagger)
