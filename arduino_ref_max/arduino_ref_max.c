/*
 * MAX30102_AVR_GCC.c
 * Compiler: AVR-GCC (Microchip Studio / Atmel Studio)
 * Target: ATmega128
 * Frequency: 16MHz
 */

#define F_CPU 16000000UL // delay.h보다 먼저 선언되어야 함

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <math.h>
#include <stdint.h>

// =================================================================
// [1] 시스템 타이머 (millis 구현)
// =================================================================
volatile unsigned long millis_counter = 0;

// CVAVR: interrupt [TIM0_COMP] -> AVR-GCC: ISR(TIMER0_COMP_vect)
ISR(TIMER0_COMP_vect) {
    millis_counter++;
}

unsigned long millis(void) {
    unsigned long m;
    uint8_t oldSREG = SREG;
    cli(); // Disable interrupts
    m = millis_counter;
    SREG = oldSREG; // Restore interrupts
    return m;
}

void Timer0_Init(void) {
    // CTC Mode, Prescaler 64
    // OCR0 = (16000000 / 64 / 1000) - 1 = 249
    TCCR0 = (1 << WGM01) | (1 << CS01) | (1 << CS00);
    TCNT0 = 0x00;
    OCR0  = 249;
    TIMSK |= (1 << OCIE0); // Interrupt Enable
}

// =================================================================
// [2] UART 및 Printf 설정 (AVR-GCC 방식)
// =================================================================
int UART0_putchar(char c, FILE *stream) {
    if (c == '\n') UART0_putchar('\r', stream);
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = c;
    return 0;
}

// printf 스트림 연결을 위한 구조체
FILE uart_output = FDEV_SETUP_STREAM(UART0_putchar, NULL, _FDEV_SETUP_WRITE);

void UART0_init(void) {
    UBRR0H = 0;
    UBRR0L = 103; // 9600bps @ 16MHz
    UCSR0B = (1 << RXEN0) | (1 << TXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit, No parity
}

// =================================================================
// [3] I2C (TWI) Functions
// =================================================================
void TWI_init(void) {
    TWSR = 0x00; 
    TWBR = 12; // 400kHz @ 16MHz
}

void TWI_start(void) {
    TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
}

void TWI_stop(void) {
    TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN);
}

void TWI_write(uint8_t data) {
    TWDR = data;
    TWCR = (1 << TWINT) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
}

uint8_t TWI_read_ack(void) {
    TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
    while (!(TWCR & (1 << TWINT)));
    return TWDR;
}

uint8_t TWI_read_nack(void) {
    TWCR = (1 << TWINT) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
    return TWDR;
}

// =================================================================
// [4] 필터 구조체 및 로직 (C++ -> C Porting)
// =================================================================
#define PI 3.1415926535

// --- 1. MinMaxAvgStatistic ---
typedef struct {
    float min_val;
    float max_val;
    float sum_val;
    int count;
} Stat_t;

void Stat_Reset(Stat_t *stat) {
    stat->min_val = 1000000.0;
    stat->max_val = -1000000.0;
    stat->sum_val = 0;
    stat->count = 0;
}

void Stat_Process(Stat_t *stat, float val) {
    if (val < stat->min_val) stat->min_val = val;
    if (val > stat->max_val) stat->max_val = val;
    stat->sum_val += val;
    stat->count++;
}

float Stat_GetAvg(Stat_t *stat) {
    if (stat->count == 0) return 0;
    return stat->sum_val / stat->count;
}

// --- 2. HighPassFilter ---
typedef struct {
    float kX, kA0, kA1, kB1;
    float last_filter_val;
    float last_raw_val;
    uint8_t init_flag;
} HPF_t;

void HPF_Init(HPF_t *filter, float cutoff, float fs) {
    float samples = fs / (cutoff * 2 * PI);
    filter->kX = exp(-1.0/samples);
    filter->kA0 = (1.0 + filter->kX) / 2.0;
    filter->kA1 = -filter->kA0;
    filter->kB1 = filter->kX;
    filter->init_flag = 0;
}

void HPF_Reset(HPF_t *filter) { filter->init_flag = 0; }

float HPF_Process(HPF_t *filter, float val) {
    if (filter->init_flag == 0) {
        filter->last_filter_val = 0;
        filter->init_flag = 1;
    } else {
        filter->last_filter_val = filter->kA0 * val 
                                + filter->kA1 * filter->last_raw_val 
                                + filter->kB1 * filter->last_filter_val;
    }
    filter->last_raw_val = val;
    return filter->last_filter_val;
}

// --- 3. LowPassFilter ---
typedef struct {
    float kA0, kB1;
    float last_val;
    uint8_t init_flag;
} LPF_t;

void LPF_Init(LPF_t *filter, float cutoff, float fs) {
    float samples = fs / (cutoff * 2 * PI);
    float kX = exp(-1.0/samples);
    filter->kA0 = 1.0 - kX;
    filter->kB1 = kX;
    filter->init_flag = 0;
}

void LPF_Reset(LPF_t *filter) { filter->init_flag = 0; }

float LPF_Process(LPF_t *filter, float val) {
    if (filter->init_flag == 0) {
        filter->last_val = val;
        filter->init_flag = 1;
    } else {
        filter->last_val = filter->kA0 * val + filter->kB1 * filter->last_val;
    }
    return filter->last_val;
}

// --- 4. Differentiator ---
typedef struct {
    float fs;
    float last_val;
    uint8_t init_flag;
} Diff_t;

void Diff_Init(Diff_t *diff, float fs) {
    diff->fs = fs;
    diff->init_flag = 0;
}

void Diff_Reset(Diff_t *diff) { diff->init_flag = 0; }

float Diff_Process(Diff_t *diff, float val) {
    float output = 0;
    if (diff->init_flag == 1) {
        output = (val - diff->last_val) * diff->fs;
    } else {
        diff->init_flag = 1;
    }
    diff->last_val = val;
    return output;
}

// =================================================================
// [5] MAX30102 제어
// =================================================================
#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF
#define REG_FIFO_DATA   0x07

void WriteReg(uint8_t r, uint8_t v) {
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(r); TWI_write(v); TWI_stop();
}

void MAX30102_Init_400Hz() {
    WriteReg(0x09, 0x40); _delay_ms(100); // Reset
    WriteReg(0x02, 0xC0); // Interrupt Enable
    WriteReg(0x08, 0x50); // FIFO Config: Avg 4
    // SpO2 Config: Range 4096nA(01), 400Hz(011), 411us(11) -> 0x2F
    WriteReg(0x0A, 0x2F); 
    WriteReg(0x0C, 0x24); // LED1 PA
    WriteReg(0x0D, 0x24); // LED2 PA
    WriteReg(0x09, 0x03); // Mode: SpO2
}

void ReadFIFO(uint32_t *r, uint32_t *ir) {
    uint8_t t[6];
    uint8_t i;
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(REG_FIFO_DATA);
    TWI_start(); TWI_write(MAX30102_ADDR_R);
    for(i=0; i<5; i++) t[i]=TWI_read_ack();
    t[5]=TWI_read_nack();
    TWI_stop();
    *r = ((uint32_t)t[0]<<16 | (uint32_t)t[1]<<8 | t[2]) & 0x3FFFF;
    *ir= ((uint32_t)t[3]<<16 | (uint32_t)t[4]<<8 | t[5]) & 0x3FFFF;
}

// =================================================================
// [6] 전역 변수 및 파라미터
// =================================================================
const float kSamplingFreq = 100.0; // FIFO Avg 4 사용 시 실제 데이터 속도
const unsigned long kFingerThreshold = 10000;
const unsigned int kFingerCooldownMs = 500;
const float kEdgeThreshold = -2000.0;

const float kLowPassCutoff = 5.0;
const float kHighPassCutoff = 0.5;

// SpO2 Coefficients
const float kSpO2_A = 1.5958422;
const float kSpO2_B = -34.6596622;
const float kSpO2_C = 112.6898759;

LPF_t lpf_red, lpf_ir;
HPF_t hpf_red;
Diff_t diff_red;
Stat_t stat_red, stat_ir;

long last_heartbeat = 0;
long finger_timestamp = 0;
uint8_t finger_detected = 0;
float last_diff = 0;
uint8_t crossed = 0;
long crossed_time = 0;

void Reset_All_Filters() {
    LPF_Reset(&lpf_red);
    LPF_Reset(&lpf_ir);
    HPF_Reset(&hpf_red);
    Diff_Reset(&diff_red);
    Stat_Reset(&stat_red);
    Stat_Reset(&stat_ir);
    finger_detected = 0;
    finger_timestamp = millis();
}

// =================================================================
// [7] Main Function
// =================================================================
int main(void) {
    // 변수 선언
    uint32_t raw_red, raw_ir;
    float f_red, f_ir, f_val, f_diff;
    long interval;
    int bpm;
    float r_red, r_ir, r, spo2;

    // 초기화
    UART0_init();
    stdout = &uart_output; // Printf 연결

    TWI_init();
    Timer0_Init();
    sei(); // Global Interrupt Enable
    
    _delay_ms(1000);
    printf("Starting MAX30102 (AVR Studio)...\r\n");
    
    MAX30102_Init_400Hz();
    
    // 필터 초기화
    LPF_Init(&lpf_red, kLowPassCutoff, kSamplingFreq);
    LPF_Init(&lpf_ir, kLowPassCutoff, kSamplingFreq);
    HPF_Init(&hpf_red, kHighPassCutoff, kSamplingFreq);
    Diff_Init(&diff_red, kSamplingFreq);
    Reset_All_Filters();

    while (1) {
        // 1. Read Sample
        ReadFIFO(&raw_red, &raw_ir);
        
        f_red = (float)raw_red;
        f_ir = (float)raw_ir;

        // 2. Finger Detection
        if (raw_red > kFingerThreshold) {
            if ((millis() - finger_timestamp) > kFingerCooldownMs) {
                finger_detected = 1;
            }
        } else {
            if (finger_detected) {
                Reset_All_Filters();
                printf("Finger Removed\r\n");
            }
        }

        if (finger_detected) {
            // 3. Low Pass Filtering
            f_red = LPF_Process(&lpf_red, f_red);
            f_ir  = LPF_Process(&lpf_ir, f_ir);

            // 4. Statistics for SpO2
            Stat_Process(&stat_red, f_red);
            Stat_Process(&stat_ir, f_ir);

            // 5. Beat Detection Logic (using RED LED)
            f_val = HPF_Process(&hpf_red, f_red); 
            f_diff = Diff_Process(&diff_red, f_val); 

            // Zero-Crossing Detection
            if (last_diff > 0 && f_diff < 0) {
                crossed = 1;
                crossed_time = millis();
            }
            
            if (f_diff > 0) {
                crossed = 0;
            }

            // Falling Edge Threshold Check
            if (crossed && f_diff < kEdgeThreshold) {
                if (last_heartbeat != 0 && (crossed_time - last_heartbeat) > 300) {
                    
                    interval = crossed_time - last_heartbeat;
                    bpm = 60000 / interval;

                    // SpO2 Calculation
                    r_red = (stat_red.max_val - stat_red.min_val) / Stat_GetAvg(&stat_red);
                    r_ir  = (stat_ir.max_val - stat_ir.min_val) / Stat_GetAvg(&stat_ir);
                    
                    r = 0;
                    if (r_ir != 0) r = r_red / r_ir;
                    
                    spo2 = kSpO2_A * r * r + kSpO2_B * r + kSpO2_C;

                    if (bpm > 40 && bpm < 220) {
                        // AVR-GCC 기본 설정에서 %f가 안 될 경우를 대비해
                        // 정수부와 소수부를 나누어 출력하거나, 링커 설정 필요
                        // 여기서는 기본 동작을 위해 정수로 출력하거나 설정 필요 메시지를 띄움
						int r_int = (int)r;
						int r_dec = (int)((r - r_int) * 100); // 예: 0.85 -> 85

						// %d.%02d 로 출력 (소수부가 5면 05로 출력되게 함)
						printf("BPM:%d, SpO2:%d, R_Ratio:%d.%02d\r\n", bpm, (int)spo2, r_int, r_dec);
                        
                    }

                    // Reset Stats
                    Stat_Reset(&stat_red);
                    Stat_Reset(&stat_ir);
                    
                    last_heartbeat = crossed_time;
                    crossed = 0;
                }
            }
            last_diff = f_diff;
        }
        
        _delay_ms(10);
    }
    return 0;
}
