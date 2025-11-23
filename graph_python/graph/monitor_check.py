import serial
import time

COM_PORT = 'COM6'
BAUD_RATE = 115200

print("--- [DEBUG MODE] Serial Raw Data Check ---")
print(f"Connecting to {COM_PORT}...")

try:
    # timeout을 설정해야 readline이 영원히 멈추지 않습니다.
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=2)
    print(f"Connected! Waiting for data...")
    
    start_time = time.time()
    
    while True:
        # 데이터가 들어올 때까지 대기하지 않고, 버퍼 상태 확인
        if ser.in_waiting > 0:
            # raw bytes로 읽어서 숨겨진 문자(\r, \n) 확인
            raw_line = ser.readline()
            try:
                decoded_line = raw_line.decode('utf-8').strip()
            except:
                decoded_line = "Decode Error"
                
            # 눈으로 확인: b'...' 형태와 디코딩된 형태 둘 다 출력
            print(f"[Time: {time.time()-start_time:.2f}s] Raw: {raw_line}  -> Decoded: {decoded_line}")
        else:
            # 데이터가 안 들어오면 점을 찍음 (멈춘건지 데이터가 없는건지 구별)
            print(".", end="", flush=True)
            time.sleep(0.1)

except serial.SerialException as e:
    print(f"\nFATAL ERROR: Could not open port. {e}")
except KeyboardInterrupt:
    print("\nClosed by user.")
    if 'ser' in locals() and ser.is_open:
        ser.close()