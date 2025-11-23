import sys
import time
import serial
from collections import deque
import numpy as np
from scipy.signal import butter, lfilter, find_peaks

# [1. GUI 백엔드 강제 설정] - 윈도우 멈춤 방지 핵심
import matplotlib
try:
    matplotlib.use('TkAgg')
    print("[시스템] GUI 백엔드를 TkAgg로 설정했습니다.")
except:
    pass

import matplotlib.pyplot as plt
import matplotlib.animation as animation

# --- [2. 사용자 설정] ---
COM_PORT = 'COM6'   
BAUD_RATE = 115200
MAX_LEN = 500       # 저장할 데이터 길이
VIEW_LEN = 200      # 화면에 보여줄 길이
FS = 25            # 샘플링 레이트 (Hz)

start_time = time.time()
low_bpm_start_time = None
is_buzzer_on = False
last_buzzer_time = 0  # [추가] 마지막으로 경고를 보낸 시간 기록
last_lcd_send_time = 0

# --- [3. 데이터 버퍼] ---
raw_buffer = deque([0] * MAX_LEN, maxlen=MAX_LEN)

# --- [4. 필터 설정] ---
def butter_bandpass(lowcut, highcut, fs, order=2):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

b_band, a_band = butter_bandpass(0.5, 5.0, FS, order=2)

# --- [5. 알고리즘 함수] ---
def process_2nd_derivative(signal_array):
    if len(signal_array) < 3: return np.zeros(len(signal_array))
    X = np.array(signal_array)
    S = np.diff(X, prepend=X[0])
    Y = np.zeros_like(S)
    Y[1:] = 13 * S[1:] + 11 * S[:-1]
    Y[0] = 0
    return Y

# --- [6. 시리얼 연결] ---
print(f"[시스템] {COM_PORT} 포트에 연결을 시도합니다...")
try:
    # timeout=0.1로 설정하여 데이터가 없어도 루프가 멈추지 않게 함
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=0.1)
    print(f"[시스템] 연결 성공! 안정화 대기 중...")
    time.sleep(1.5)
    ser.reset_input_buffer()
except Exception as e:
    print(f"[오류] 시리얼 연결 실패: {e}")
    sys.exit()

# --- [7. 그래프 초기화] ---
try:
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
    plt.subplots_adjust(hspace=0.4)
except Exception as e:
    print(f"[오류] 그래프 창 생성 실패: {e}")
    sys.exit()

# 상단: Raw Data & Filtered
line_raw, = ax1.plot([], [], 'k-', alpha=0.3, label='Raw Data')
line_filt, = ax1.plot([], [], 'b-', linewidth=1.5, label='Filtered (0.5-5Hz)')
ax1.set_title('PPG Signal Processing')
ax1.grid(True)
ax1.legend(loc='upper right')
ax1.set_xlim(0, VIEW_LEN)
ax1.set_ylim(-800, 800) # 초기 범위 (데이터에 따라 자동 조정될 수 있음)

# 하단: 2차 미분 & Peak
line_deriv, = ax2.plot([], [], 'r-', linewidth=1.5, label='2nd Derivative')
peak_scatter, = ax2.plot([], [], 'go', label='Peaks')
ax2.set_title('Feature Extraction & Heart Rate')
ax2.grid(True)
ax2.set_xlim(0, VIEW_LEN)
ax2.set_ylim(-5000, 5000)

bpm_text = ax2.text(0.02, 0.9, 'Initializing...', transform=ax2.transAxes, 
                    fontsize=14, fontweight='bold', color='blue')

# --- [8. 부저 로직] ---
def handle_output(bpm, current_time):
    global low_bpm_start_time, is_buzzer_on, last_buzzer_time, last_lcd_send_time
    
    # 1. 상태 판별 (정상: N, 경고: W)
    # 기준: 50 ~ 120 BPM을 정상으로 가정 (필요에 따라 수정)
    status_char = 'N'
    if bpm <= 30:
        status_char = 'W'

    # 2. LCD 및 제어 데이터 전송 (1초에 한 번만 실행)
    # PC가 연산한 BPM과 상태를 ATmega로 전송합니다.
    # 포맷: <BPM,상태>  예: <75,N> 또는 <40,W>
    if (current_time - last_lcd_send_time) >= 1.0:
        last_lcd_send_time = current_time
        msg = f"<{int(bpm)},{status_char}>"
        try:
            ser.write(msg.encode())
            print(f"[전송] {msg}") # 디버깅용
        except Exception as e:
                print(f"[전송 오류] {e}")

    # 3. 부저 로직 (기존 로직 유지하되, 상태에 따라 작동)
    # 경고 상태(W)이고 저심박이 지속되면 부저 경고
    # if bpm <= 30:
    #     if low_bpm_start_time is None:
    #         low_bpm_start_time = current_time
    #     elif (current_time - low_bpm_start_time) >= 3.0:
    #         pass 
    # else:
    #     low_bpm_start_time = None
    
    

# --- [9. 메인 업데이트 루프] ---
def update(frame):
    global raw_buffer, start_time

    # (A) 시리얼 데이터 읽기 (안정적인 방식)
    read_count = 0
    while ser.in_waiting > 0 and read_count < 20: # 한 프레임당 최대 20개만 처리
        try:
            line = ser.readline()
            if not line: break
            
            decoded = line.decode('utf-8', errors='ignore').strip()
            if not decoded: continue
            
            val = int(decoded)
            if (val < 1000):
                # 손 안대고 있으면 무시
                continue 
            raw_buffer.append(val)
            read_count += 1
        except ValueError:
            continue # 숫자가 아니면 무시
        except Exception:
            break

    # 데이터가 충분히 쌓일 때까지 대기
    if len(raw_buffer) < 50:
        bpm_text.set_text(f'Buffering... ({len(raw_buffer)}/{MAX_LEN})')
        return line_raw, line_filt, line_deriv, peak_scatter, bpm_text

    # (B) 신호 처리
    try:
        data_np = np.array(raw_buffer)
        
        # 1. 필터링
        filtered_data = lfilter(b_band, a_band, data_np)
        
        # 2. 2차 미분 (Feature Extraction)
        deriv_data = process_2nd_derivative(filtered_data)
        
        # 3. 화면 표시용 데이터 자르기 (최신 VIEW_LEN 개수만)
        show_raw = data_np[-VIEW_LEN:] - np.mean(data_np[-VIEW_LEN:]) # DC 제거 후 표시
        show_filt = filtered_data[-VIEW_LEN:]
        show_deriv = deriv_data[-VIEW_LEN:]
        
        # (C) BPM 계산
        bpm = 0.0
        peaks_x_view = []
        peaks_y_view = []

        if len(show_deriv) > 50:
            # 동적 임계값 설정
            curr_max = np.max(show_deriv)
            if curr_max < 10: curr_max = 10
            threshold = curr_max * 0.55
            
            # 피크 찾기
            peaks, _ = find_peaks(show_deriv, height=threshold, distance=int(FS/2.5))
            
            if len(peaks) > 0:
                peaks_x_view = peaks
                peaks_y_view = show_deriv[peaks]
                
                # 피크 간격으로 BPM 계산
                if len(peaks) > 1:
                    intervals = np.diff(peaks)
                    mean_interval = np.mean(intervals)
                    if mean_interval > 0:
                        bpm = 60.0 / (mean_interval / FS)

        # (D) PC -> ATmega 데이터 전송
        current_time = time.time()
        # 시작 후 5초 뒤부터 데이터 전송 시작 (초기 노이즈 방지)
        if (current_time - start_time) > 5:
            handle_output(bpm, current_time)

        # (E) 그래프 데이터 업데이트
        x_axis = np.arange(len(show_raw))
        
        line_raw.set_data(x_axis, show_raw)
        line_filt.set_data(x_axis, show_filt)
        line_deriv.set_data(x_axis, show_deriv)
        
        if len(peaks_x_view) > 0:
            peak_scatter.set_data(peaks_x_view, peaks_y_view)
        else:
            peak_scatter.set_data([], [])

        bpm_text.set_text(f'Heart Rate: {bpm:.1f} BPM')

        # (F) Y축 오토 스케일링 (옵션: 그래프가 잘리면 이 주석을 푸세요)
        # ax1.set_ylim(np.min(show_raw)-50, np.max(show_raw)+50)
        # ax2.set_ylim(np.min(show_deriv)-500, np.max(show_deriv)+500)
        
    except Exception as e:
        print(f"[업데이트 오류] {e}")

    return line_raw, line_filt, line_deriv, peak_scatter, bpm_text

# --- [10. 실행] ---
print("[시스템] 그래프 창을 띄웁니다...")
# blit=False: 윈도우 호환성을 위해 필수
ani = animation.FuncAnimation(fig, update, interval=30, blit=False, cache_frame_data=False)

plt.show(block=True)
print("[시스템] 프로그램 종료")
ser.close()