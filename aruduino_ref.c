/*
 * MAX30102_Lite_Optimized.c
 * Compiler: CodeVisionAVR (Evaluation Compatible)
 * Target: ATmega128 / 16MHz
 */

#include <mega128a.h>
#include <delay.h>
#include <stdio.h>
// #include <math.h>  <-- 삭제! (용량 절약)
#include <stdint.h>

// =================================================================
// [1] 시스템 시간 (millis)
// =================================================================
volatile unsigned long millis_counter = 0;

interrupt [TIM0_COMP] void timer0_comp_isr(void) {
    millis_counter++;
}

unsigned long millis(void) {
    unsigned long m;
    #asm("cli")
    m = millis_counter;
    #asm("sei")
    return m;
}

void Timer0_Init(void) {
    // CTC Mode, Prescaler 64
    TCCR0 = (1<<WGM01) | (1<<CS01) | (1<<CS00);
    TCNT0 = 0x00;
    OCR0  = 249; 
    TIMSK |= (1<<OCIE0);
}


// =================================================================
// [3] 필터 구조체 (계산식 제거 및 상수화)
// =================================================================
// Sampling Freq: 100Hz 기준 상수로 미리 계산함

// Low Pass Filter (Cutoff 5Hz)
// kX = exp(-1/(100/(5*2*pi))) = 0.7304
// kA0 = 1 - 0.7304 = 0.2696
// kB1 = 0.7304
typedef struct {
    float last_val;
    unsigned char init_flag;
} LPF_t;

void LPF_Reset(LPF_t *filter) { filter->init_flag = 0; }

float LPF_Process(LPF_t *filter, float val) {
    if (filter->init_flag == 0) {
        filter->last_val = val;
        filter->init_flag = 1;
    } else {
        // 상수 0.2696, 0.7304 직접 사용
        filter->last_val = 0.2696 * val + 0.7304 * filter->last_val;
    }
    return filter->last_val;
}

// High Pass Filter (Cutoff 0.5Hz)
// kX = exp(-1/(100/(0.5*2*pi))) = 0.969
// kA0 = (1+0.969)/2 = 0.9845
// kA1 = -0.9845
// kB1 = 0.969
typedef struct {
    float last_filter_val;
    float last_raw_val;
    unsigned char init_flag;
} HPF_t;

void HPF_Reset(HPF_t *filter) { filter->init_flag = 0; }

float HPF_Process(HPF_t *filter, float val) {
    if (filter->init_flag == 0) {
        filter->last_filter_val = 0;
        filter->init_flag = 1;
    } else {
        // 상수 직접 사용
        filter->last_filter_val = 0.9845 * val 
                                - 0.9845 * filter->last_raw_val 
                                + 0.9690 * filter->last_filter_val;
    }
    filter->last_raw_val = val;
    return filter->last_filter_val;
}

// Differentiator
typedef struct {
    float last_val;
    unsigned char init_flag;
} Diff_t;

void Diff_Reset(Diff_t *diff) { diff->init_flag = 0; }

float Diff_Process(Diff_t *diff, float val) {
    float output = 0;
    if (diff->init_flag == 1) {
        // Sampling Rate 100.0 곱하기
        output = (val - diff->last_val) * 100.0;
    } else {
        diff->init_flag = 1;
    }
    diff->last_val = val;
    return output;
}

// Statistic (SpO2용)
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

// =================================================================
// [4] 하드웨어 제어
// =================================================================
#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF

void UART0_init(void) {
    UBRR0H = 0; UBRR0L = 103; // 9600bps
    UCSR0B = (1<<RXEN0)|(1<<TXEN0); 
    UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
}

void TWI_init(void) { TWSR=0x00; TWBR=12; }
void TWI_start(void) { TWCR=(1<<TWINT)|(1<<TWSTA)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); }
void TWI_stop(void) { TWCR=(1<<TWINT)|(1<<TWSTO)|(1<<TWEN); }
void TWI_write(uint8_t d) { TWDR=d; TWCR=(1<<TWINT)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); }
uint8_t TWI_read_ack(void) { TWCR=(1<<TWINT)|(1<<TWEN)|(1<<TWEA); while(!(TWCR&(1<<TWINT))); return TWDR; }
uint8_t TWI_read_nack(void) { TWCR=(1<<TWINT)|(1<<TWEN); while(!(TWCR&(1<<TWINT))); return TWDR; }

void WriteReg(uint8_t r, uint8_t v) {
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(r); TWI_write(v); TWI_stop();
}

void MAX30102_Init_400Hz() {
    WriteReg(0x09, 0x40); delay_ms(100); 
    WriteReg(0x02, 0xC0); 
    WriteReg(0x08, 0x50); 
    WriteReg(0x0A, 0x2F); 
    WriteReg(0x0C, 0x24); 
    WriteReg(0x0D, 0x24); 
    WriteReg(0x09, 0x03); 
}

void ReadFIFO(uint32_t *r, uint32_t *ir) {
    uint8_t t[6];
    unsigned char i;
    TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(0x07);
    TWI_start(); TWI_write(MAX30102_ADDR_R);
    for(i=0; i<5; i++) t[i]=TWI_read_ack();
    t[5]=TWI_read_nack();
    TWI_stop();
    *r = ((uint32_t)t[0]<<16 | (uint32_t)t[1]<<8 | t[2]) & 0x3FFFF;
    *ir= ((uint32_t)t[3]<<16 | (uint32_t)t[4]<<8 | t[5]) & 0x3FFFF;
}

// =================================================================
// [5] 메인 함수
// =================================================================
// 전역 변수로 선언하여 스택 오버플로우 방지 및 초기화 편의
LPF_t lpf_red, lpf_ir;
HPF_t hpf_red;
Diff_t diff_red;
Stat_t stat_red, stat_ir;

long last_heartbeat = 0;
long finger_timestamp = 0;
unsigned char finger_detected = 0;
float last_diff = 0;
unsigned char crossed = 0;
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

void main(void) {
    uint32_t raw_red, raw_ir;
    float f_red, f_ir, f_val, f_diff;
    long interval;
    int bpm;
    float r_red, r_ir, r, spo2;
    int r_int, r_dec;

    UART0_init();
    TWI_init();
    Timer0_Init();
    
    #asm("sei")
    
    delay_ms(1000);
    printf("System Ready (Lite)\r\n");
    
    MAX30102_Init_400Hz();
    Reset_All_Filters();

    while (1) {
        ReadFIFO(&raw_red, &raw_ir);
        
        f_red = (float)raw_red;
        f_ir = (float)raw_ir;

        // 손가락 감지 (Threshold 10000)
        if (raw_red > 10000) {
            if ((millis() - finger_timestamp) > 500) {
                finger_detected = 1;
            }
        } else {
            if (finger_detected) {
                Reset_All_Filters();
                printf("Finger Removed\r\n");
            }
        }

        if (finger_detected) {
            // 필터 처리
            f_red = LPF_Process(&lpf_red, f_red);
            f_ir  = LPF_Process(&lpf_ir, f_ir);
            
            Stat_Process(&stat_red, f_red);
            Stat_Process(&stat_ir, f_ir);

            f_val = HPF_Process(&hpf_red, f_red); 
            f_diff = Diff_Process(&diff_red, f_val); 

            // Beat Detection
            if (last_diff > 0 && f_diff < 0) {
                crossed = 1;
                crossed_time = millis();
            }
            if (f_diff > 0) crossed = 0;

            // Edge Check (-2000.0)
            if (crossed && f_diff < -2000.0) {
                if (last_heartbeat != 0 && (crossed_time - last_heartbeat) > 300) {
                    
                    interval = crossed_time - last_heartbeat;
                    bpm = 60000 / interval;

                    r_red = (stat_red.max_val - stat_red.min_val) / Stat_GetAvg(&stat_red);
                    r_ir  = (stat_ir.max_val - stat_ir.min_val) / Stat_GetAvg(&stat_ir);
                    
                    r = 0;
                    if (r_ir != 0) r = r_red / r_ir;
                    
                    // SpO2 = A*r^2 + B*r + C
                    spo2 = 1.5958 * r * r - 34.659 * r + 112.689;

                    if (bpm > 40 && bpm < 220) {
                        r_int = (int)r;
                        r_dec = (int)((r - r_int) * 100);
                        if(r_dec < 0) r_dec = -r_dec;

                        printf("BPM:%d, SpO2:%d, R:%d.%02d\r\n", bpm, (int)spo2, r_int, r_dec);
                    }

                    Stat_Reset(&stat_red);
                    Stat_Reset(&stat_ir);
                    
                    last_heartbeat = crossed_time;
                    crossed = 0;
                }
            }
            last_diff = f_diff;
        }
        
        delay_ms(10);
    }
}