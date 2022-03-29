import time
import os
import json
import numpy
import random

class CommunicationManager():
    def __init__(self, ):
        self.comData = {
            'aliceConnect': False,
            'bobConnect': False,
            'aliceSharedBits': False,
            'bobSharedBits': False,

            'aliceSharedBases': False,
            'bobSharedBases': False,
            'aliceWaitingForMeasurement': False,
            'bobWaitingForMeasurement': False,
        }
        # TODO: write some safet/backup mechanism for restarting the server
        # initialise some random data

    def saveData(self, data):
        # TODO: write a check for the correct Format
        self.comData = data
    def getData(self):
        return self.comData