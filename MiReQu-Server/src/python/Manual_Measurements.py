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


def convert_toJson(fileNameNPY,fileNameJsoN):
    ## Convertiert das numpy array zum JsoN format, das ist aber nicht die Form die der Export haben sollte

    import json
    data = np.load(fileNameNPY,allow_pickle=True)#[1:,:]

    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            if (type(data[i,j])==np.ndarray): data[i,j] = data[i,j].tolist()
            if (type(data[i,j])==np.float64): data[i,j] = float(data[i,j])


    dict = {"data":data.tolist()}

    json = json.dumps(dict)
    f = open(fileNameJsoN,"w")
    f.write(json)
    f.close()


if __name__ == "__main__":
    import numpy as np
    import matplotlib.pyplot as plt
    import json

    dirname = os.path.dirname(PySide2.__file__)
    plugin_path = os.path.join(dirname, 'plugins', 'platforms')
    os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = plugin_path

    rEncoder = rotEncoderInterface("COM12")  # Port Hauptversuch
    tagger = createTimeTagger()
    ccStream = CoincidencesNoUI(tagger)

    fileName = "Manual_measurements/"+"20210319_"+"PM_WinkelSweep"

    offset1 = 52.01569
    offset2 = 286.21476

    messzeit = 1
    maxtime = 10 # maximal 10s in der jetzigen implementierung

    print("Measurements Starts")
    time.sleep(messzeit+0.2)

    pos1, pos2, = np.round((rEncoder.getPos00()-offset1+360)%360,1),np.round((rEncoder.getPos01()-offset2+360)%360,1)

    s1 = np.flip(ccStream.counter.getData()[0]*ccStream.getCouterNormalizationFactor()*1000)[: round(99 * messzeit/maxtime)]
    s2 = np.flip(ccStream.counter.getData()[1]*ccStream.getCouterNormalizationFactor()*1000)[: round(99 * messzeit/maxtime)]
    cc = np.flip(ccStream.counter.getData()[2]*ccStream.getCouterNormalizationFactor()*1000)[: round(99 * messzeit/maxtime)]


    if not os.path.exists(fileName+'.npy'):
        data_Array = np.array((["alpha(deg)", "beta(deg)", "counts1(Hz)", "counts2(Hz)", "coincidences(Hz)"],[pos1, pos2, s1, s2, cc]))

        np.save(fileName+'.npy',data_Array)
    else:
        old_data = np.load(fileName+'.npy',allow_pickle=True)

        new_data = np.empty((old_data.shape[0]+1,5),dtype="object")
        print("new Shape: {:}".format(new_data.shape))
        new_data[:-1,:] = old_data
        new_data[-1,:] = np.array(([pos1, pos2, s1, s2, cc]))
        np.save(fileName + '.npy', new_data)



    print("Measured: {:};  {:};  {:}+-{:};  {:}+-{:};  {:}+-{:}".format(pos1,pos2,np.average(s1),np.round(np.std(s1),1),np.average(s2),
                                                                   np.round(np.std(s2),1),np.average(cc),np.round(np.std(cc),1)))
    freeTimeTagger(tagger)
    convert_toJson(fileName + '.npy',fileName + '.json')


