import serial
import time
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque

# --- 설정 부분 (사용자 환경에 맞게 수정) ---
COM_PORT = 'COM6'  # 장치 관리자에서 확인한 포트 번호로 변경 (예: 'COM3')
BAUD_RATE = 9600   # ATmega128 코드와 동일하게 설정

# --- 데이터 저장용 변수 ---
MAX_LEN = 200      # 그래프에 보여줄 최대 데이터 개수
raw_data = deque([0] * MAX_LEN, maxlen=MAX_LEN)
filtered_data = deque([0] * MAX_LEN, maxlen=MAX_LEN)

# --- 심박수 계산용 변수 ---
last_peak_time = 0
bpm_values = deque(maxlen=10) # 최근 10개 BPM의 평균을 사용하기 위함
current_bpm = 0

# --- 시리얼 포트 연결 ---
try:
    ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
    print(f"Connected to {COM_PORT}")
    time.sleep(2) # 연결 안정화 대기
except serial.SerialException:
    print(f"Error: Could not open {COM_PORT}. Check the port number and close other terminals.")
    exit()

# --- 그래프 설정 ---
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
plt.subplots_adjust(hspace=0.4)

# Raw Data 그래프
line1, = ax1.plot([], [], 'r-', lw=1)
ax1.set_title('Raw Red LED Data')
ax1.set_ylabel('Amplitude')
ax1.set_xlim(0, MAX_LEN)
ax1.grid(True)

# Filtered Data (Heart Beat) 그래프
line2, = ax2.plot([], [], 'b-', lw=1.5)
ax2.set_title('Filtered PPG (Heart Beat Signal)')
ax2.set_ylabel('Amplitude')
ax2.set_xlabel('Samples')
ax2.set_xlim(0, MAX_LEN)
ax2.grid(True)

# BPM 텍스트 표시
bpm_text = ax2.text(0.02, 0.9, '', transform=ax2.transAxes, fontsize=12, fontweight='bold', color='blue')

# --- 심박수 계산 함수 ---
def calculate_bpm(new_val):
    global last_peak_time, current_bpm
    
    # 간단한 피크 감지 로직 (Threshold 방식)
    # 현재 값이 일정 임계값(예: 50)을 넘고, 이전보다 클 때 (상승 에지 등)
    # 실제로는 더 정교한 알고리즘(이동 평균 등)이 필요하지만 여기선 간단히 구현
    
    # 현재 시간을 초 단위로 가져옴
    curr_time = time.time()
    
    # Filtered 데이터 버퍼의 마지막 값들을 확인하여 피크인지 판별
    if len(filtered_data) > 3:
        # 간단한 로컬 피크 감지: 현재 값이 양옆 값보다 크고, 특정 임계값(예: 20) 이상일 때
        threshold = 50 
        y = list(filtered_data)
        if y[-2] > threshold and y[-2] > y[-3] and y[-2] > y[-1]:
            # 피크 감지됨
            if last_peak_time != 0:
                delta_t = curr_time - last_peak_time
                # 0.25초(240 BPM) ~ 2.0초(30 BPM) 사이의 간격만 유효한 심박으로 인정
                if 0.25 < delta_t < 2.0:
                    instant_bpm = 60.0 / delta_t
                    bpm_values.append(instant_bpm)
                    current_bpm = sum(bpm_values) / len(bpm_values) # 이동 평균
            
            last_peak_time = curr_time

# --- 애니메이션 업데이트 함수 ---
def update(frame):
    global raw_data, filtered_data
    
    while ser.in_waiting: # 시리얼 버퍼에 데이터가 있으면 읽음
        try:
            line = ser.readline().decode('utf-8').strip()
            if ',' in line:
                raw_str, filt_str = line.split(',')
                raw_val = int(raw_str)
                filt_val = int(filt_str)
                
                # 데이터 저장
                raw_data.append(raw_val)
                filtered_data.append(filt_val)
                
                # BPM 계산 시도
                calculate_bpm(filt_val)
                
        except ValueError:
            pass # 파싱 에러 무시
        except Exception as e:
            print(f"Error: {e}")

    # 그래프 데이터 업데이트
    line1.set_data(range(len(raw_data)), raw_data)
    line2.set_data(range(len(filtered_data)), filtered_data)
    
    # Y축 범위 자동 조정 (최근 데이터 기준)
    if len(raw_data) > 0:
        ax1.set_ylim(min(raw_data)-100, max(raw_data)+100)
    if len(filtered_data) > 0:
        # 필터된 데이터는 0 근처에서 움직이므로 범위를 좁게 잡음
        min_f = min(filtered_data)
        max_f = max(filtered_data)
        margin = max(abs(min_f), abs(max_f)) * 0.2 + 10
        ax2.set_ylim(min_f - margin, max_f + margin)

    # BPM 텍스트 업데이트
    bpm_text.set_text(f'Heart Rate: {current_bpm:.1f} BPM')

    return line1, line2, bpm_text

# --- 애니메이션 실행 ---
# interval=10ms 마다 update 함수 호출
ani = animation.FuncAnimation(fig, update, interval=10, blit=True)

plt.show()

# 종료 시 포트 닫기
ser.close()