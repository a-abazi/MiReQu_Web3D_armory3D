import serial
import time


def posRead(serial):
    b = serial.readline()
    string_n = b.decode()  # decode byte string into Unicode
    string = string_n.rstrip()  # remove \n and \r
    return  string  # convert string to float


ser = serial.Serial('COM3', 9600)
time.sleep(.1)
ser.write("<check>".encode("utf8"))
print("arduino at port is " + posRead(ser))
time.sleep(.1)

ser.write("<get00>".encode("utf8"))
print (int(posRead(ser)))


#while True:
#    currPos = posRead(ser)
#    print(currPos)

ser.close()


