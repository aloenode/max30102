/*
 * MAX30102_ADI_Algorithm.c
 * Compiler: CodeVisionAVR
 * Target: ATmega128 / 16MHz
 * Reference: ADI Technical Article - PPG Beat Interval Detection
 */

#include <mega128a.h>
#include <delay.h>
#include <stdio.h>
#include <stdint.h>

// --- 전역 타이머 변수 ---
volatile unsigned long millis_counter = 0;

interrupt [TIM0_COMP] void timer0_comp_isr(void) {
    millis_counter++;
}

// --- MAX30102 & I2C Definitions ---
#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF
#define REG_INTR_ENABLE_1 0x02
#define REG_FIFO_DATA     0x07
#define REG_FIFO_CONFIG   0x08
#define REG_MODE_CONFIG   0x09
#define REG_SPO2_CONFIG   0x0A
#define REG_LED1_PA       0x0C
#define REG_LED2_PA       0x0D

// --- UART ---
void UART0_init(void) {
    UBRR0H = 0; UBRR0L = 103; // 9600bps
    UCSR0B = (1 << RXEN0) | (1 << TXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}
void putchar(char c) { while (!(UCSR0A & (1 << UDRE0))); UDR0 = c; }

// --- I2C ---
void TWI_init(void) { TWSR=0x00; TWBR=72; }
void TWI_start(void) { TWCR=(1<<TWINT)|(1<<TWSTA)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); }
void TWI_stop(void) { TWCR=(1<<TWINT)|(1<<TWSTO)|(1<<TWEN); }
void TWI_write(uint8_t data) { TWDR=data; TWCR=(1<<TWINT)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); }
uint8_t TWI_read_ack(void) { TWCR=(1<<TWINT)|(1<<TWEN)|(1<<TWEA); while(!(TWCR&(1<<TWINT))); return TWDR; }
uint8_t TWI_read_nack(void) { TWCR=(1<<TWINT)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); return TWDR; }

void MAX30102_WriteReg(uint8_t reg, uint8_t val) {
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(reg); TWI_write(val); TWI_stop();
}

void MAX30102_Init() {
    MAX30102_WriteReg(REG_MODE_CONFIG, 0x40); delay_ms(100);
    MAX30102_WriteReg(REG_INTR_ENABLE_1, 0xC0);
    MAX30102_WriteReg(REG_FIFO_CONFIG, 0x50);
    MAX30102_WriteReg(REG_SPO2_CONFIG, 0x27); 
    MAX30102_WriteReg(REG_LED1_PA, 0x24); 
    MAX30102_WriteReg(REG_LED2_PA, 0x24); 
    MAX30102_WriteReg(REG_MODE_CONFIG, 0x03);
}

void MAX30102_ReadFIFO(uint32_t *red, uint32_t *ir) {
    uint8_t temp[6];
    int i;
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(REG_FIFO_DATA);
    TWI_start(); TWI_write(MAX30102_ADDR_R);
    for(i=0; i<5; i++) temp[i] = TWI_read_ack();
    temp[5] = TWI_read_nack();
    TWI_stop();
    *red = ((uint32_t)temp[0]<<16 | (uint32_t)temp[1]<<8 | temp[2]) & 0x3FFFF;
    *ir  = ((uint32_t)temp[3]<<16 | (uint32_t)temp[4]<<8 | temp[5]) & 0x3FFFF;
}

void Timer0_Init(void) {
    TCCR0 = (1 << WGM01) | (0 << CS02) | (1 << CS01) | (1 << CS00); // CTC, Prescaler 64
    TCNT0 = 0x00; OCR0 = 249; TIMSK |= (1 << OCIE0);
}

// =================================================================
// [ADI 알고리즘 기반 변수]
// =================================================================
#define FINGER_ON_THRESHOLD 50000 
#define BEAT_MIN_TIME_MS    300
#define MA_SIZE             4  // 이동 평균 필터 크기 (Smoothing)

float dc_filter_ir = 0;
float ma_buffer[MA_SIZE];   // 이동 평균 버퍼
int ma_idx = 0;

float prev_derivative = 0;  // 이전 기울기
float current_derivative = 0; // 현재 기울기

unsigned long last_beat_time = 0;

void main(void) {
    uint32_t red_val, ir_val;
    int bpm = 0;
    unsigned long delta = 0; 
    unsigned long current_millis; 
    
    // 필터링 변수
    float ac_signal;
    float smoothed_signal = 0;
    float sum_ma = 0;
    int i;

    UART0_init();
    TWI_init();
    Timer0_Init();
    
    #asm("sei")
    
    delay_ms(1000);
    printf("ADI Algorithm based BPM Monitor\r\n");
    MAX30102_Init();

    // 이동 평균 버퍼 초기화
    for(i=0; i<MA_SIZE; i++) ma_buffer[i] = 0;

    while (1) {
        current_millis = millis_counter;
        MAX30102_ReadFIFO(&red_val, &ir_val);

        if (ir_val < FINGER_ON_THRESHOLD) {
            ir_val = 0; dc_filter_ir = 0; bpm = 0;
            // 버퍼 초기화
            for(i=0; i<MA_SIZE; i++) ma_buffer[i] = 0;
            printf("No Finger\r\n");
        } 
        else {
            // ---------------------------------------------------
            // 1단계: 전처리 (Preprocessing) 
            // ---------------------------------------------------
            
            // 1-1. DC 제거 (High-pass Filter 역할, 0.4Hz 이상 통과)
            dc_filter_ir = (float)ir_val * 0.05 + dc_filter_ir * 0.95;
            ac_signal = (float)ir_val - dc_filter_ir;

            // 1-2. 스무딩 (Low-pass FIR Filter 역할, Moving Average)
            // 고주파 노이즈를 제거하여 미분 시 노이즈 증폭 방지
            sum_ma = 0;
            ma_buffer[ma_idx] = ac_signal;
            ma_idx = (ma_idx + 1) % MA_SIZE;
            
            for(i=0; i<MA_SIZE; i++) sum_ma += ma_buffer[i];
            smoothed_signal = sum_ma / MA_SIZE;

            // ---------------------------------------------------
            // 2단계: 딜리니에이션 (Delineation) 
            // ---------------------------------------------------
            
            // 2-1. 도함수(기울기) 계산
            // 현재 신호와 바로 직전 신호(이동평균 필터 거친 값)의 차이
            static float last_smoothed = 0;
            current_derivative = smoothed_signal - last_smoothed;
            
            // 2-2. Zero-Crossing 검출 (Valley Detection)
            // 기울기가 음수(-)에서 양수(+)로 바뀌는 순간이 골짜기(Valley)의 최저점입니다.
            // (이전 기울기 < 0) AND (현재 기울기 > 0)
            
            if (prev_derivative < 0 && current_derivative > 0) {
                
                // 추가 조건: 신호의 깊이(Amplitude) 확인 (노이즈 방지)
                if (smoothed_signal < -50) { 
                    
                    if ((current_millis - last_beat_time) > BEAT_MIN_TIME_MS) {
                        delta = current_millis - last_beat_time;
                        last_beat_time = current_millis;
                        
                        if(delta != 0) bpm = 60000 / delta;
                    }
                }
            }

            // 다음 루프를 위해 값 저장
            last_smoothed = smoothed_signal;
            prev_derivative = current_derivative;
        }

        if(bpm > 200 || bpm < 40) bpm = 0;
        
        // 디버깅을 위해 스무딩된 신호 출력
        printf("BPM:%d, IR_AC:%d\r\n", bpm, (int)smoothed_signal);

        delay_ms(10); 
    }
}