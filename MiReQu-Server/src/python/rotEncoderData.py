import serial
import time

class rotEncoderInterface():

    def __init__(self,  comPort:str):
        self.ser = serial.Serial(comPort, 9600)
        time.sleep(.01)
        self.ser.write("<check>".encode("utf8"))
        print("arduino at USB port " +comPort+" is " + self.posRead())
        time.sleep(.01)

    def getPos00(self):
        self.ser.write("<get00>".encode("utf8"))
        return int(self.posRead())
    def getPos01(self):
        self.ser.write("<get01>".encode("utf8"))
        return int(self.posRead())
    def getPos02(self):
        self.ser.write("<get02>".encode("utf8"))
        return int(self.posRead())

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
    rEncoder = rotEncoderInterface("COM3")
    for i in range(1000):
        print("RotEncoder:")
        print(rEncoder.getPos00(),rEncoder.getPos01(),rEncoder.getPos02())
        print("Voltage:")
        print(rEncoder.getSens01()/1023.*5.,rEncoder.getSens02()/1023.*5.)
        time.sleep(0.1)
    rEncoder.close()