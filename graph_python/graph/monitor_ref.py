import serial
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
from scipy.signal import butter, lfilter, find_peaks

# --- [1. 사용자 설정] ---
COM_PORT = 'COM6'   # ★ 포트 번호 수정 필요
BAUD_RATE = 9600
MAX_LEN = 500
VIEW_LEN = 200
FS = 25             # ★ 실제 전송 속도 (BPM 뻥튀기 방지용)

# --- [2. 데이터 버퍼] ---
raw_buffer = deque([0] * MAX_LEN, maxlen=MAX_LEN)

# --- [3. 필터 설정] ---
def butter_bandpass(lowcut, highcut, fs, order=2):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

b_band, a_band = butter_bandpass(0.5, 5.0, FS, order=2)

# --- [4. 알고리즘 함수] ---
def process_2nd_derivative(signal_array):
    if len(signal_array) < 3: return np.zeros(len(signal_array))
    X = np.array(signal_array)
    S = np.diff(X, prepend=X[0])
    Y = np.zeros_like(S)
    Y[1:] = 13 * S[1:] + 11 * S[:-1]
    Y[0] = 0
    return Y

# --- [5. 시리얼 연결] ---
try:
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print(f"Connected to {COM_PORT}.")
except Exception as e:
    print(f"Error: {e}")
    exit()

# --- [6. 그래프 초기화 (축 고정 설정)] ---
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
plt.subplots_adjust(hspace=0.4)

# 상단: Raw Data
line_raw, = ax1.plot([], [], 'k-', alpha=0.3, label='Raw Data (Centered)')
line_filt, = ax1.plot([], [], 'b-', linewidth=1.5, label='Bandpass Filtered')
ax1.set_title('PPG Signal Processing')
ax1.set_ylabel('Amplitude')
ax1.legend(loc='upper right')
ax1.grid(True)

# ★ [수정] 상단 Y축 고정 (Raw Data가 움직일 공간 확보)
# 이 범위 밖으로 나가면 잘려서 안 보입니다. 너무 작으면 숫자를 늘리세요.
ax1.set_ylim(-800, 800) 

# 하단: 2차 미분
line_deriv, = ax2.plot([], [], 'r-', linewidth=1.5, label='2nd Derivative (Y)')
peak_scatter, = ax2.plot([], [], 'go', label='Detected Peaks')
ax2.set_title('Feature Extraction & Heart Rate')
ax2.set_ylabel('Enhanced Amplitude')
ax2.grid(True)

# ★ [수정] 하단 Y축 고정
ax2.set_ylim(-9000, 5000)

bpm_text = ax2.text(0.02, 0.9, 'Initializing...', transform=ax2.transAxes, 
                    fontsize=14, fontweight='bold', color='blue')

# --- [7. 메인 업데이트] ---
def update(frame):
    global raw_buffer
    
    while ser.in_waiting:
        try:
            line = ser.readline().decode('utf-8', errors='ignore').strip()
            if not line: continue
            parts = line.split(',')
            if len(parts) >= 1:
                raw_buffer.append(int(parts[0]))
        except: pass
    
    if len(raw_buffer) < 50: return line_raw, line_filt, line_deriv, bpm_text, peak_scatter

    # 1. 데이터 가공
    data_np = np.array(raw_buffer)
    filtered_data = lfilter(b_band, a_band, data_np)
    deriv_data = process_2nd_derivative(filtered_data)
    
    # 2. 화면 자르기 (Sliding Window)
    if len(deriv_data) > VIEW_LEN:
        # Raw 데이터는 DC성분이 크므로 화면 중앙(0)에 오도록 평균을 뺌 (Centering)
        # 이렇게 해야 고정된 Y축(-2000~2000) 안에 들어옵니다.
        raw_segment = data_np[-VIEW_LEN:]
        show_raw = raw_segment - np.mean(raw_segment)
        
        show_filt = filtered_data[-VIEW_LEN:]
        show_deriv = deriv_data[-VIEW_LEN:]
    else:
        show_raw = data_np - np.mean(data_np)
        show_filt = filtered_data
        show_deriv = deriv_data

    # 3. BPM 계산
    bpm = 0.0
    dp_x, dp_y = [], []
    
    if len(show_deriv) > 50:
        # 문턱값 설정 (최대값의 55%)
        curr_max = np.percentile(show_deriv, 99)
        if curr_max < 10: curr_max = 10
        threshold = curr_max * 0.55
        min_dist = int(FS / 2.0)
        
        peaks, _ = find_peaks(show_deriv, height=threshold, distance=min_dist)
        
        if len(peaks) > 0:
            dp_x = peaks
            dp_y = show_deriv[peaks]
            if len(peaks) > 1:
                mean_interval = np.mean(np.diff(peaks))
                if mean_interval > 0:
                    bpm = 60.0 / (mean_interval / FS)

    # 4. 그래프 업데이트 (축 변경 코드 없음!)
    x_axis = np.arange(len(show_raw))
    
    line_raw.set_data(x_axis, show_raw)
    line_filt.set_data(x_axis, show_filt)
    ax1.set_xlim(0, VIEW_LEN)
    # ★ 여기에 ax1.set_ylim(...) 코드가 없어야 축이 고정됩니다.

    line_deriv.set_data(x_axis, show_deriv)
    ax2.set_xlim(0, VIEW_LEN)
    
    if len(dp_x) > 0:
        peak_scatter.set_data(dp_x, dp_y)
    else:
        peak_scatter.set_data([], [])
        
    bpm_text.set_text(f'Heart Rate: {bpm:.1f} BPM')
    
    return line_raw, line_filt, line_deriv, peak_scatter, bpm_text

ani = animation.FuncAnimation(fig, update, interval=20, blit=True, cache_frame_data=False)
plt.show()
ser.close()