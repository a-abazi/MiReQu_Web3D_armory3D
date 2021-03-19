# docs @ http://flask.pocoo.org/docs/1.0/quickstart/
from src.python.timeTaggerData import CoincidencesNoUI
from src.python.rotEncoderData import rotEncoderInterface
from src.python.ExportManager import ExportManager


from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
import sys, os
import PySide2
import numpy as np
import time

# all required TimeTagger dependencies
from TimeTagger import Coincidences, Counter, Correlation, createTimeTagger, freeTimeTagger




if __name__ == "__main__":
    import numpy as np
    import matplotlib.pyplot as plt

    dirname = os.path.dirname(PySide2.__file__)
    plugin_path = os.path.join(dirname, 'plugins', 'platforms')
    os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path

    rEncoder = rotEncoderInterface("COM12")  # Port Hauptversuch
    tagger = createTimeTagger()
    ccStream = CoincidencesNoUI(tagger)

    fileName = "Manual_measurements/"+"20210319_sParameter"

    offset1 = 1
    offset2 = 2

    print("Measurements Starts")
    time.sleep(10)

    pos1, pos2, = np.round(rEncoder.getPos00()-offset1,1),np.round(rEncoder.getPos00()-offset2,1)

    s1 = np.flip(ccStream.counter.getData()[0]* ccStream.getCouterNormalizationFactor()*1000)#.tolist()
    s2 = np.flip(ccStream.counter.getData()[1]* ccStream.getCouterNormalizationFactor()*1000)#.tolist()
    cc = np.flip(ccStream.counter.getData()[2]* ccStream.getCouterNormalizationFactor()*1000)#.tolist()

    if not os.path.exists(fileName+'.txt'):
        f = open(fileName+'.txt', "a+")
        print("New file created {:}".format(fileName))
        f.write("#{:};{:};{:};{:};{:}".format("alpha(deg)", "beta(deg)", "counts1(Hz)", "counts2(Hz)", "coincidences(Hz)"))
        f.write("\n{:};{:};{:};{:};{:}".format(pos1,pos2,s1,s2,cc))
    else:
        print("Appended to file {:}".format(fileName))
        f = open(fileName+'.txt', "a+")
        f.write("\n{:};{:};{:};{:};{:}".format(pos1,pos2,s1,s2,cc))

    print("Measured: {:};{:};{:}+-{:} ;{:}+-{:} ;{:}+- {:}".format(pos1,pos2,np.average(s1),np.std(s1),np.average(s2),
                                                                   np.std(s2),np.average(cc),np.std(cc)))

    f.close()

