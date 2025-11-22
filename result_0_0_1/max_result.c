#include <mega128.h>
#include <delay.h>
#include <stdio.h>
#include <stdint.h> // uint8_t, uint32_t 등을 위해 필요

// I2C(TWI) 제어용 비트 정의 (mega128.h에 정의가 안 되어 있을 경우를 대비)
#ifndef TWINT
#define TWINT 7
#define TWEA  6
#define TWSTA 5
#define TWSTO 4
#define TWWC  3
#define TWEN  2
#endif

// --- MAX30102 I2C 주소 ---
#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF

// --- 레지스터 주소 ---
#define REG_INTR_STATUS_1 0x00
#define REG_INTR_STATUS_2 0x01
#define REG_FIFO_WR_PTR   0x04
#define REG_OVF_COUNTER   0x05
#define REG_FIFO_RD_PTR   0x06
#define REG_FIFO_DATA     0x07
#define REG_FIFO_CONFIG   0x08
#define REG_MODE_CONFIG   0x09
#define REG_SPO2_CONFIG   0x0A
#define REG_LED1_PA       0x0C
#define REG_LED2_PA       0x0D

// --- TWI (I2C) 초기화 및 제어 함수 ---
void TWI_init(void) {
    // SCL 주파수 설정: 16MHz 기준 약 100kHz
    TWSR = 0x00; // Prescaler = 1
    TWBR = 72;   
    TWCR = (1 << TWEN); // TWI 활성화
}

void TWI_start(void) {
    TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT))); // 완료 대기
}

void TWI_stop(void) {
    TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN);
}

void TWI_write(unsigned char data) {
    TWDR = data;
    TWCR = (1 << TWINT) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
}

unsigned char TWI_read_ack(void) {
    TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
    while (!(TWCR & (1 << TWINT)));
    return TWDR;
}

unsigned char TWI_read_nack(void) {
    TWCR = (1 << TWINT) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
    return TWDR;
}

// --- MAX30102 제어 함수 ---
void MAX30102_writeReg(unsigned char reg, unsigned char value) {
    TWI_start();
    TWI_write(MAX30102_ADDR_W);
    TWI_write(reg);
    TWI_write(value);
    TWI_stop();
}

unsigned char MAX30102_readReg(unsigned char reg) {
    unsigned char data;
    TWI_start();
    TWI_write(MAX30102_ADDR_W);
    TWI_write(reg);
    TWI_start(); // Repeated Start
    TWI_write(MAX30102_ADDR_R);
    data = TWI_read_nack();
    TWI_stop();
    return data;
}

void MAX30102_init(void) {
    // 1. Reset
    MAX30102_writeReg(REG_MODE_CONFIG, 0x40);
    delay_ms(100);

    // 2. FIFO Config: Sample Avg=4, Rollover=Enable
    MAX30102_writeReg(REG_FIFO_CONFIG, 0x50); 

    // 3. Mode Config: SpO2 Mode (Red + IR)
    MAX30102_writeReg(REG_MODE_CONFIG, 0x03); 

    // 4. SpO2 Config: ADC Range 4096nA, 100Hz, 411us Pulse
    MAX30102_writeReg(REG_SPO2_CONFIG, 0x27); 

    // 5. LED Pulse Amplitude (약 6~7mA)
    MAX30102_writeReg(REG_LED1_PA, 0x24); 
    MAX30102_writeReg(REG_LED2_PA, 0x24); 

    // 포인터 초기화
    MAX30102_writeReg(REG_FIFO_WR_PTR, 0x00);
    MAX30102_writeReg(REG_OVF_COUNTER, 0x00);
    MAX30102_writeReg(REG_FIFO_RD_PTR, 0x00);
}

// FIFO 읽기 함수 (성공 시 1 리턴)
unsigned char MAX30102_readFIFO(uint32_t *red_led, uint32_t *ir_led) {
    unsigned char ptr_w, ptr_r;
    unsigned char d[6];
    int i;
    
    ptr_w = MAX30102_readReg(REG_FIFO_WR_PTR);
    ptr_r = MAX30102_readReg(REG_FIFO_RD_PTR);

    if (ptr_w == ptr_r) return 0; // 데이터 없음

    // Burst Read
    TWI_start();
    TWI_write(MAX30102_ADDR_W);
    TWI_write(REG_FIFO_DATA);
    TWI_start();
    TWI_write(MAX30102_ADDR_R);

    for(i=0; i<5; i++) d[i] = TWI_read_ack();
    d[5] = TWI_read_nack();
    TWI_stop();

    // 데이터 조합 (18비트)
    *red_led = ((uint32_t)d[0] << 16 | (uint32_t)d[1] << 8 | d[2]) & 0x03FFFF;
    *ir_led  = ((uint32_t)d[3] << 16 | (uint32_t)d[4] << 8 | d[5]) & 0x03FFFF;

    return 1;
}

// DC 제거 필터
long getDCremoved(uint32_t raw_value) {
    static long prev_w = 0;
    long w;
    long result;
    
    // Low pass filter logic to remove DC
    w = raw_value + (long)(0.95 * prev_w);
    result = w - prev_w;
    prev_w = w;
    
    return result;
}

// UART0 초기화 (printf 사용을 위함)
void UART0_init(void) {
    UCSR0B = 0x18; // RXEN, TXEN
    UCSR0C = 0x06; // 8 Data, 1 Stop, No Parity
    UBRR0L = 103;  // 9600bps @ 16MHz
    UBRR0H = 0;
}

// CVAVR에서는 printf가 내부적으로 putchar를 호출함 (설정에 따라 자동 생성됨)
// 만약 printf가 동작하지 않으면 프로젝트 설정에서 UART를 활성화해야 함

void main(void) {
    uint32_t red_val, ir_val;
    long red_filtered;
    long threshold = 100; // 감지 임계값 (상황에 맞춰 조절 필요)
    
    // 하드웨어 초기화
    UART0_init();
    TWI_init();
    
    printf("MAX30102 Init...\r\n");
    MAX30102_init();
    printf("Init Done.\r\n");

    while (1) {
        if (MAX30102_readFIFO(&red_val, &ir_val)) {
            // 필터링
            red_filtered = getDCremoved(red_val);

            // 간단한 출력 (Serial Plotter용)
            // Raw 값과 필터링된 값을 출력
            printf("%ld,%ld\r\n", red_val, red_filtered);
            
            // 심박 감지 로직은 필터링된 값이 threshold를 넘길 때를 체크하면 됩니다.
        }
        delay_ms(5);
    }
}