import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import threading
import time

# ==========================================
# [설정]
# ==========================================
COM_PORT = 'COM6'   # 본인 포트 번호 확인 (예: 'COM5')
BAUD_RATE = 115200  # ATmega128 설정과 동일
MAX_LEN = 200       # X축 데이터 길이

# [수정됨] 파형 그래프 Y축 고정 범위 설정
# 파형이 짤리면 이 숫자를 늘리세요 (예: -2000, 2000)
WAVE_Y_MIN = -600
WAVE_Y_MAX = 600

# 데이터 저장소
bpm_data = deque([0] * MAX_LEN, maxlen=MAX_LEN)
wave_data = deque([0] * MAX_LEN, maxlen=MAX_LEN)

# 현재 BPM
current_bpm = 0

ser = None

def init_serial():
    global ser
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
        print(f"Successfully connected to {COM_PORT} @ {BAUD_RATE}bps")
        time.sleep(2)
    except Exception as e:
        print(f"Error: {e}")
        exit()

def read_serial_data():
    global current_bpm
    while True:
        if ser and ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                parts = line.split(',')
                
                # 데이터 순서: RAW, AC, TH, STATE, BPM
                if len(parts) >= 5:
                    ac_val = int(parts[1])  # 파형
                    bpm_val = int(parts[4]) # BPM
                    
                    wave_data.append(ac_val)
                    bpm_data.append(bpm_val)
                    
                    current_bpm = bpm_val
            except:
                pass

# 그래프 설정
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
plt.subplots_adjust(hspace=0.4)

def animate(i):
    # --- [1] 위쪽: BPM 그래프 ---
    ax1.clear()
    ax1.plot(bpm_data, color='#FF5252', linewidth=2, label='BPM')
    ax1.set_title('Real-time Heart Rate', fontsize=14, fontweight='bold')
    ax1.set_ylabel('BPM')
    
    # BPM 그래프는 범위가 자동 조절되도록 둠 (최소 150)
    if len(bpm_data) > 0:
        top = max(150, max(bpm_data) + 10)
        ax1.set_ylim(0, top)
        
        ax1.text(0.95, 0.85, f"♥ {current_bpm} BPM", transform=ax1.transAxes, 
                 fontsize=20, color='red', fontweight='bold', ha='right',
                 bbox=dict(facecolor='white', alpha=0.8, edgecolor='red'))
    
    ax1.grid(True, alpha=0.3, linestyle='--')

    # --- [2] 아래쪽: 파형 그래프 (Y축 고정) ---
    ax2.clear()
    ax2.plot(wave_data, color='#448AFF', linewidth=1.5, label='Pulse Wave')
    ax2.set_title('Raw PPG Waveform', fontsize=14, fontweight='bold')
    ax2.set_ylabel('Amplitude')
    
    # [수정됨] Y축 범위를 강제로 고정합니다!
    ax2.set_ylim(WAVE_Y_MIN, WAVE_Y_MAX)
    
    ax2.grid(True, alpha=0.3, linestyle='--')

if __name__ == '__main__':
    init_serial()
    
    thread = threading.Thread(target=read_serial_data)
    thread.daemon = True
    thread.start()
    
    print("Monitor Started (Fixed Y-Axis)...")
    ani = animation.FuncAnimation(fig, animate, interval=50, cache_frame_data=False)
    plt.show()
    
    if ser: ser.close()