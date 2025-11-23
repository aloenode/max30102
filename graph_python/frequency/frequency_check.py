import serial
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.widgets import TextBox
from collections import deque
import time
from scipy import signal

# ==========================================
# 기본 설정
# ==========================================
SERIAL_PORT = 'COM6'
BAUD_RATE = 115200
MAX30102_FS = 100       # 샘플링 레이트
BUFFER_SIZE = 256       # 버퍼 크기

# 초기 필터 값 (실행 후 우측 패널에서 변경 가능)
current_low_cut = 0.8
current_high_cut = 3.5
FILTER_ORDER = 2

# 데이터 저장소
data_buffer = deque([0] * BUFFER_SIZE, maxlen=BUFFER_SIZE)

# 시리얼 연결
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    time.sleep(2)
    ser.reset_input_buffer()
    print(f"연결 성공: {SERIAL_PORT}")
except Exception as e:
    print(f"연결 실패: {e}")
    exit()

# ==========================================
# 화면 레이아웃 설정 (좌측: 그래프 4개, 우측: 입력창)
# ==========================================
fig = plt.figure(figsize=(14, 10)) # 전체 창 크기
plt.subplots_adjust(left=0.1, bottom=0.05, right=0.75, top=0.95, hspace=0.4)

# 그래프 위치 지정
ax1 = fig.add_subplot(4, 1, 1) # Raw Time
ax2 = fig.add_subplot(4, 1, 2) # Raw FFT
ax3 = fig.add_subplot(4, 1, 3) # Filtered Time
ax4 = fig.add_subplot(4, 1, 4) # Filtered FFT

# 1. Raw Data
line1, = ax1.plot([], [], lw=1, color='tab:blue')
ax1.set_title('1. Raw Signal (Time Domain)')
ax1.set_xlim(0, BUFFER_SIZE)
ax1.grid()

# 2. Raw FFT
line2, = ax2.plot([], [], lw=1, color='tab:orange')
ax2.set_title('2. Raw FFT (Frequency Domain) - Find Noise Here!')
ax2.set_xlim(0, 10) # 10Hz까지만 분석
ax2.set_ylim(0, 50000) # Raw FFT는 값이 크므로 적절히 조절
ax2.grid()

# 3. Filtered Data
line3, = ax3.plot([], [], lw=2, color='tab:green')
ax3.set_title(f'3. Filtered Signal')
ax3.set_xlim(0, BUFFER_SIZE)
ax3.set_ylim(-1000, 1000) # 필터 데이터 범위 고정
ax3.grid()

# 4. Filtered FFT
line4, = ax4.plot([], [], lw=2, color='tab:red')
ax4.set_title('4. Filtered FFT - Check Heartbeat Peak')
ax4.set_xlim(0, 10)
ax4.set_ylim(0, 30000) # 필터 FFT 범위 고정
ax4.grid()

# ==========================================
# 우측 입력 컨트롤 패널 설정
# ==========================================
# 입력창 위치: [left, bottom, width, height]
axbox_low = plt.axes([0.8, 0.6, 0.1, 0.05])
axbox_high = plt.axes([0.8, 0.5, 0.1, 0.05])
ax_text_info = plt.axes([0.8, 0.3, 0.15, 0.1]) # 정보 표시용 (투명)
ax_text_info.axis('off')

# TextBox 생성
text_box_low = TextBox(axbox_low, 'Low Cut (Hz): ', initial=str(current_low_cut))
text_box_high = TextBox(axbox_high, 'High Cut (Hz): ', initial=str(current_high_cut))

# 정보 텍스트 (현재 설정값 표시)
info_text = ax_text_info.text(0, 1, f"Current Filter:\n{current_low_cut} ~ {current_high_cut} Hz", fontsize=12, va='top')

# 입력 콜백 함수
def submit_low(text):
    global current_low_cut
    try:
        val = float(text)
        if 0 < val < current_high_cut:
            current_low_cut = val
            update_title_and_info()
        else:
            print("Low Cut must be > 0 and < High Cut")
    except ValueError:
        print("Invalid Number")

def submit_high(text):
    global current_high_cut
    try:
        val = float(text)
        if val > current_low_cut and val < MAX30102_FS/2:
            current_high_cut = val
            update_title_and_info()
        else:
            print(f"High Cut must be > Low Cut and < {MAX30102_FS/2}")
    except ValueError:
        print("Invalid Number")

def update_title_and_info():
    ax3.set_title(f'3. Filtered Signal ({current_low_cut} ~ {current_high_cut} Hz)')
    info_text.set_text(f"Current Filter:\n{current_low_cut} ~ {current_high_cut} Hz\n\nPress Enter\nafter typing!")
    plt.draw()

text_box_low.on_submit(submit_low)
text_box_high.on_submit(submit_high)


# ==========================================
# 데이터 처리 및 필터 함수
# ==========================================
def apply_filter(data, lowcut, highcut, fs, order=2):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='band')
    return signal.filtfilt(b, a, data)

def update(frame):
    # 데이터 읽기
    while ser.in_waiting > 0:
        try:
            line = ser.readline().decode('utf-8').strip()
            if line:
                data_buffer.append(int(line))
        except:
            pass
            
    if len(data_buffer) < BUFFER_SIZE:
        return line1, line2, line3, line4

    # 데이터 준비
    raw_data = np.array(data_buffer)
    # FFT 분석을 위한 Detrend (DC 제거)
    raw_detrended = raw_data - np.mean(raw_data)
    
    # ---------------------------------------------
    # 1. Raw Data Plot
    # ---------------------------------------------
    x_axis = np.arange(len(raw_data))
    line1.set_data(x_axis, raw_data)
    if np.max(raw_data) != np.min(raw_data):
        m = (np.max(raw_data) - np.min(raw_data)) * 0.1
        ax1.set_ylim(np.min(raw_data)-m, np.max(raw_data)+m)

    # ---------------------------------------------
    # 2. Raw FFT Plot
    # ---------------------------------------------
    raw_fft = np.fft.rfft(raw_detrended)
    raw_mag = np.abs(raw_fft)
    freqs = np.fft.rfftfreq(BUFFER_SIZE, 1/MAX30102_FS)
    
    line2.set_data(freqs, raw_mag)
    # Raw FFT는 값이 튈 수 있으니 자동 스케일 추천, 너무 크면 고정
    if np.max(raw_mag) > 0:
        ax2.set_ylim(0, np.max(raw_mag)*1.1)

    # ---------------------------------------------
    # 3. Filtered Data Plot (동적 파라미터 적용)
    # ---------------------------------------------
    # 현재 입력창에 설정된 값으로 필터링 수행
    try:
        filtered_data = apply_filter(raw_detrended, current_low_cut, current_high_cut, MAX30102_FS, FILTER_ORDER)
        line3.set_data(x_axis, filtered_data)
        # 축 고정 (필요시 자동 스케일로 변경 가능)
        # ax3.set_ylim(-1000, 1000) 
    except Exception as e:
        print(f"Filter Error: {e}")
        return line1, line2, line3, line4

    # ---------------------------------------------
    # 4. Filtered FFT Plot
    # ---------------------------------------------
    filt_fft = np.fft.rfft(filtered_data)
    filt_mag = np.abs(filt_fft)
    
    line4.set_data(freqs, filt_mag)
    # 여기는 심박 피크를 잘 보기 위해 고정된 범위나 약간의 자동 조절 사용
    # 관심 대역(Low~High) 내의 최대값 기준으로 스케일링하면 보기 좋음
    mask = (freqs >= current_low_cut) & (freqs <= current_high_cut)
    if np.any(mask):
        max_val = np.max(filt_mag[mask])
        if max_val > 0:
            ax4.set_ylim(0, max_val * 2.0)

    return line1, line2, line3, line4

# 애니메이션 실행
ani = FuncAnimation(fig, update, interval=30, blit=False)
plt.show()

ser.close()