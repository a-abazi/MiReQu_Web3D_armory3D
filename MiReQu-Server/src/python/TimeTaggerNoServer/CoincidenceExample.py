# PySide2 for the UI
from PySide2.QtWidgets import QMainWindow, QApplication, QFileDialog
from PySide2.QtCore import QTimer

# matplotlib for the plots, including its Qt backend
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg, NavigationToolbar2QT
from matplotlib.figure import Figure

# generated file by: pyuic5 CoincidenceExampleWindow.ui > CoincidenceExampleWindow.py
# Please use the QtDesigner to edit the ui interface file
from .CoincidenceExampleWindow import Ui_CoincidenceExample

# numpy and math for statistical analysis
import numpy
import math

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger


class CoincidenceExample(QMainWindow):
    ''' Small example of how to create a UI for the TimeTagger with the PySide2 framework'''

    def __init__(self, tagger):
        '''Constructor of the coincidence example window
        The TimeTagger object must be given as arguments to support running many windows at once.'''

        # Create the UI from the designer file and connect its action buttons
        super(CoincidenceExample, self).__init__()
        self.ui = Ui_CoincidenceExample()
        self.ui.setupUi(self)
        self.ui.startButton.clicked.connect(self.startClicked)
        self.ui.stopButton.clicked.connect(self.stopClicked)
        self.ui.clearButton.clicked.connect(self.clearClicked)
        self.ui.saveButton.clicked.connect(self.saveClicked)

        # Update the measurements whenever any input configuration changes
        self.ui.channelA.valueChanged.connect(self.updateMeasurements)
        self.ui.channelB.valueChanged.connect(self.updateMeasurements)
        self.ui.delayA.valueChanged.connect(self.updateMeasurements)
        self.ui.delayB.valueChanged.connect(self.updateMeasurements)
        self.ui.triggerA.valueChanged.connect(self.updateMeasurements)
        self.ui.triggerB.valueChanged.connect(self.updateMeasurements)
        self.ui.testsignalA.stateChanged.connect(self.updateMeasurements)
        self.ui.testsignalB.stateChanged.connect(self.updateMeasurements)
        self.ui.coincidenceWindow.valueChanged.connect(self.updateMeasurements)
        self.ui.correlationBinwidth.valueChanged.connect(
            self.updateMeasurements)
        self.ui.correlationBins.valueChanged.connect(self.updateMeasurements)

        # Create the matplotlib figure with its subplots for the counter and correlation
        self.fig = Figure()
        self.counterAxis = self.fig.add_subplot(211)
        self.correlationAxis = self.fig.add_subplot(212)
        self.canvas = FigureCanvasQTAgg(self.fig)
        self.toolbar = NavigationToolbar2QT(self.canvas, self)
        self.ui.plotLayout.addWidget(self.toolbar)
        self.ui.plotLayout.addWidget(self.canvas)

        # Create the TimeTagger measurements
        self.running = True
        self.measurements_dirty = False
        self.tagger = tagger
        self.last_channels = [0, 0]
        self.last_coincidenceWindow = 0
        self.updateMeasurements()

        # Use a timer to redraw the plots every 100ms
        self.draw()
        self.timer = QTimer()
        self.timer.timeout.connect(self.draw)
        self.timer.start(100)

    def getCouterNormalizationFactor(self):
        bin_index = self.counter.getIndex()
        # normalize 'clicks / bin' to 'kclicks / second'
        return 1e12 / bin_index[1] / 1e3

    def updateMeasurements(self):
        '''Create/Update all TimeTagger measurement objects'''

        # If any configuration is changed while the measurements are stopped, recreate them on the start button
        if not self.running:
            self.measurements_dirty = True
            return

        # Set the input delay, trigger level, and test signal of both channels
        channels = [self.ui.channelA.value(), self.ui.channelB.value()]
        self.tagger.setInputDelay(channels[0], self.ui.delayA.value())
        self.tagger.setInputDelay(channels[1], self.ui.delayB.value())
        self.tagger.setTriggerLevel(channels[0], self.ui.triggerA.value())
        self.tagger.setTriggerLevel(channels[1], self.ui.triggerB.value())
        self.tagger.setTestSignal(channels[0], self.ui.testsignalA.isChecked())
        self.tagger.setTestSignal(channels[1], self.ui.testsignalB.isChecked())

        # Only recreate the counter if its parameter has changed,
        # else we'll clear the count trace too often
        coincidenceWindow = self.ui.coincidenceWindow.value()
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
                binwidth=int(50e9),
                n_values=200
            )

        # Measure the correlation between A and B
        self.correlation = Correlation(
            self.tagger,
            channels[1],
            channels[0],
            self.ui.correlationBinwidth.value(),
            self.ui.correlationBins.value()
        )

        # Create the measurement plots
        self.counterAxis.clear()
        self.plt_counter = self.counterAxis.plot(
            self.counter.getIndex() * 1e-12,
            self.counter.getData().T * self.getCouterNormalizationFactor()
        )
        self.counterAxis.set_xlabel('time (s)')
        self.counterAxis.set_ylabel('count rate (kEvents/s)')
        self.counterAxis.set_title('Count rate')
        self.counterAxis.legend(['A', 'B', 'coincidences'])
        self.counterAxis.grid(True)

        self.correlationAxis.clear()
        index = self.correlation.getIndex()
        data = self.correlation.getDataNormalized()
        self.plt_correlation = self.correlationAxis.plot(
            index * 1e-3,
            data
        )
        self.plt_gauss = self.correlationAxis.plot(
            index * 1e-3,
            data,
            linestyle='--'
        )
        self.correlationAxis.axvspan(
            -coincidenceWindow/1000.,
            coincidenceWindow/1000.,
            color='green',
            alpha=0.3
        )
        self.correlationAxis.set_xlabel('time (ns)')
        self.correlationAxis.set_ylabel('normalized correlation')
        self.correlationAxis.set_title('Correlation between A and B')
        self.correlationAxis.grid(True)

        # Generate nicer plots
        self.fig.tight_layout()

        self.measurements_dirty = False

        # Update the plot with real numbers
        self.draw()

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

    def clearClicked(self):
        '''Handler for the clear action button'''
        self.correlation.clear()

    def saveClicked(self):
        '''Handler for the save action button'''

        # Ask for a filename
        filename, _ = QFileDialog().getSaveFileName(
            parent=self,
            caption='Save to File',
            directory='CoincidenceExampleData.txt',  # default name
            filter='All Files (*);;Text Files (*.txt)',
            options=QFileDialog.DontUseNativeDialog
        )

        # And write all results to disk
        if filename:
            with open(filename, 'w') as f:
                f.write('Input channel A: %d\n' % self.ui.channelA.value())
                f.write('Input channel B: %d\n' % self.ui.channelB.value())
                f.write('Input delay A: %d ps\n' % self.ui.delayA.value())
                f.write('Input delay B: %d ps\n' % self.ui.delayB.value())
                f.write('Trigger level A: %.3f V\n' % self.ui.triggerA.value())
                f.write('Trigger level B: %.3f V\n' % self.ui.triggerB.value())
                f.write('Test signal A: %d\n' %
                        self.ui.testsignalA.isChecked())
                f.write('Test signal B: %d\n' %
                        self.ui.testsignalB.isChecked())

                f.write('Coincidence window: %d ps\n' %
                        self.ui.coincidenceWindow.value())
                f.write('Correlation bin width: %d ps\n' %
                        self.ui.correlationBinwidth.value())
                f.write('Correlation bins: %d\n\n' %
                        self.ui.correlationBins.value())

                f.write('Counter data:\n%s\n\n' %
                        self.counter.getData().__repr__())
                f.write('Correlation data:\n%s\n\n' %
                        self.correlation.getData().__repr__())

    def resizeEvent(self, event):
        '''Handler for the resize events to update the plots'''
        self.fig.tight_layout()
        self.canvas.draw()

    def draw(self):
        '''Handler for the timer event to update the plots'''
        if self.running:
            # Counter
            data = self.counter.getData() * self.getCouterNormalizationFactor()
            for data_line, plt_counter in zip(data, self.plt_counter):
                plt_counter.set_ydata(data_line)
            self.counterAxis.relim()
            self.counterAxis.autoscale_view(True, True, True)

            # Calculate the expectation and the standard derivation of the correlation
            # With this two values, we can display a Gaussian fit
            index = self.correlation.getIndex()
            data = self.correlation.getDataNormalized()
            total = float(sum(data))
            if total > 0:
                offset = sum(data * index) / total
                stdd = math.sqrt(sum(data * (index - offset)**2) / total)
            else:
                offset = 0
                stdd = 0
            if stdd > 0:
                gauss = self.ui.correlationBinwidth.value() * total / math.sqrt(2*math.pi*stdd**2) * \
                    numpy.exp(- 0.5 * (index - offset)**2 / stdd**2)
            else:
                gauss = index * 0

            # Correlation
            self.plt_correlation[0].set_ydata(
                self.correlation.getDataNormalized())
            self.plt_gauss[0].set_ydata(gauss)
            self.correlationAxis.relim()
            self.correlationAxis.autoscale_view(True, True, True)
            self.correlationAxis.legend(['measured correlation', '$\mu$=%.1fps, $\sigma$=%.1fps' % (
                offset, stdd), 'coincidence window'])
            self.canvas.draw()


# If this file is executed, initialize PySide2, create a TimeTagger object, and show the UI
if __name__ == '__main__':
    import sys
    import os
    import PySide2

    dirname = os.path.dirname(PySide2.__file__)
    plugin_path = os.path.join(dirname, 'plugins', 'platforms')
    os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path

    app = QApplication(sys.argv)


    tagger = createTimeTagger()

    # If you want to include this window within a bigger UI,
    # just copy these two lines within any of your handlers.
    window = CoincidenceExample(tagger)

    window.show()

    app.exec_()

    freeTimeTagger(tagger)
