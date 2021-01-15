import serial
import time

class rotEncoderInterface():

    def __init__(self,  comPort:str):
        self.ser = serial.Serial(comPort, 9600)
        time.sleep(.01)
        self.ser.write("<check>".encode("utf8"))
        print("arduino at USB port " +comPort+" is " + self.posRead())
        time.sleep(.01)
        self.faktorRot = 1./ 2.224603175
        self.lastValuesRot = [0,0,0]
        self.lastValuesSens = [0, 0, 0]

    def getPos00(self):
        self.ser.write("<get00>".encode("utf8"))
        value = self.posRead()

        try:
            value = int(value)
            value = value * self.faktorRot
            value = value % 360
            if value<0: value = value + 360.

            self.lastValuesRot[0] = value
        except: value = self.lastValuesRot[0]

        return value

    def getPos01(self):
        self.ser.write("<get01>".encode("utf8"))
        value = self.posRead()
        try:
            value = int(value)
            value = value * self.faktorRot
            self.lastValuesRot[1] = value
            value = value % 360
            if value < 0: value = value + 360.
        except: value = self.lastValuesRot[1]

        return value

    def getPos02(self):
        self.ser.write("<get02>".encode("utf8"))
        value = self.posRead()
        try:
            value = int(value)
            value = value * self.faktorRot
            self.lastValuesRot[2] = value
            value = value % 360
            if value < 0: value = value + 360.
        except: value = self.lastValuesRot[2]

        return value

    def getSens01(self):
        self.ser.write("<agt01>".encode("utf8"))
        return int(self.posRead())
    def getSens02(self):
        self.ser.write("<agt02>".encode("utf8"))
        return int(self.posRead())

    def posRead(self):
        b = self.ser.readline()
        string_n = b.decode()  # decode byte string into Unicode
        string = string_n.rstrip()  # remove \n and \r
        return  string  # convert string to float

    def close(self):
        self.ser.close()


if __name__ == '__main__':
    import numpy as np
    rEncoder = rotEncoderInterface("COM5")

    #measurements = 50
    #vs = np.zeros(measurements)
#
    #for j in range(10000000):
    #    for i in range(measurements):
    #        vs[i] = rEncoder.getSens01() / 1023. * 5.
    #        time.sleep(1/measurements)
    #    print("Voltage [mV]:")
    #    print(np.average(vs)*1000,np.std(vs)*1000)

    for j in range(10000000):
        print(rEncoder.getPos00(),rEncoder.getPos01(),rEncoder.getPos02(), rEncoder.getSens01(), rEncoder.getSens02())
        time.sleep(0.005)


    rEncoder.close()