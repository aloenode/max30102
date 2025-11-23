import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import threading
import time

# ==========================================
# [사용자 설정] 포트 번호를 확인하세요!
# ==========================================
COM_PORT = 'COM3'  # 예: 'COM3', 'COM5' (장치관리자 확인)
BAUD_RATE = 9600
MAX_DATA_POINTS = 200

# 데이터 버퍼
bpm_data = deque([0] * MAX_DATA_POINTS, maxlen=MAX_DATA_POINTS)
ir_ac_data = deque([0] * MAX_DATA_POINTS, maxlen=MAX_DATA_POINTS)

ser = None

def init_serial():
    global ser
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
        print(f"Successfully connected to {COM_PORT}")
        time.sleep(2)
    except Exception as e:
        print(f"Error opening port: {e}")
        exit()

def read_serial_data():
    while True:
        if ser and ser.in_waiting > 0:
            try:
                # 데이터 읽기
                raw_line = ser.readline().decode('utf-8', errors='ignore').strip()
                
                # [디버깅] 들어오는 모든 데이터를 콘솔에 출력 (중요!)
                if raw_line:
                    print(f"[AVR]: {raw_line}")

                # 데이터 파싱 (BPM:72, IR_AC:-500 형식일 때만 처리)
                if raw_line.startswith("BPM"):
                    parts = raw_line.split(',')
                    if len(parts) >= 2:
                        # BPM:72 -> 72 추출
                        bpm_str = parts[0].split(':')[1]
                        # IR_AC:-500 -> -500 추출
                        ir_str = parts[1].split(':')[1]
                        
                        bpm = int(bpm_str)
                        ir_ac = int(ir_str)
                        
                        bpm_data.append(bpm)
                        ir_ac_data.append(ir_ac)
            except Exception as e:
                # 파싱 에러는 무시 (가끔 깨진 데이터가 들어올 수 있음)
                pass

# 그래프 설정
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
plt.subplots_adjust(hspace=0.4)

def animate(i):
    # 1. BPM 그래프
    ax1.clear()
    ax1.plot(bpm_data, color='r', label='BPM')
    ax1.set_title('Real-time Heart Rate')
    ax1.set_ylabel('BPM')
    
    # Y축 범위 동적 조절
    if len(bpm_data) > 0:
        current_max = max(bpm_data)
        top_limit = max(150, current_max + 20)
        ax1.set_ylim(0, top_limit)
        
        # 현재 BPM 텍스트 표시
        current_bpm = bpm_data[-1]
        ax1.text(MAX_DATA_POINTS - 20, top_limit * 0.8, 
                 f'{current_bpm} BPM', fontsize=14, color='red', fontweight='bold')
    
    ax1.legend(loc='upper right')
    ax1.grid(True, alpha=0.3)

    # 2. IR 파형 그래프
    ax2.clear()
    ax2.plot(ir_ac_data, color='b', label='Pulse Wave')
    ax2.set_title('Raw PPG Waveform')
    ax2.set_ylabel('Amplitude')
    ax2.legend(loc='upper right')
    ax2.grid(True, alpha=0.3)

if __name__ == '__main__':
    init_serial()
    
    # 데이터 수신 스레드 시작
    thread = threading.Thread(target=read_serial_data)
    thread.daemon = True
    thread.start()
    
    print("Graph Started... waiting for data.")
    
    # [수정] cache_frame_data=False 추가하여 경고 제거
    ani = animation.FuncAnimation(fig, animate, interval=50, cache_frame_data=False)
    plt.show()
    
    if ser: ser.close()