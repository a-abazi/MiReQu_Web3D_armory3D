import time
import os
import json
import numpy
import random

class CommunicationManager():
    def __init__(self, ):
        self.comData = {
            'aliceConnect': random.randint(0,1),
            'bobConnect': random.randint(0,1),
            'aliceSharedBits': random.randint(0,1),
            'bobSharedBits': random.randint(0,1),

            'aliceSharedBases': random.randint(0,1),
            'bobSharedBases': random.randint(0,1),
            'aliceWaitingForMeasurement': random.randint(0,1),
            'bobWaitingForMeasurement': random.randint(0,1),
        }
        # TODO: write some safet/backup mechanism for restarting the server
        # initialise some random data

    def saveData(self, data):
        # TODO: write a check for the correct Format
        self.comData = data
    def getData(self):
        return self.comData