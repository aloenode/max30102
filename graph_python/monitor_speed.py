import serial
import time

COM_PORT = 'COM6'  # 포트 번호 확인
BAUD_RATE = 9600

try:
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print(f"Checking Sampling Rate on {COM_PORT}...")
    
    count = 0
    start_time = time.time()
    
    while True:
        if ser.in_waiting:
            ser.readline()
            count += 1
            
        # 1초마다 들어온 데이터 개수 출력
        if time.time() - start_time >= 1.0:
            print(f"Actual FS (Hz): {count}")
            count = 0
            start_time = time.time()
            
except KeyboardInterrupt:
    ser.close()
except Exception as e:
    print(f"Error: {e}")