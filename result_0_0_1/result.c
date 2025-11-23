#include <mega128.h>
#include <delay.h>
#include <stdio.h>
#include <stdint.h>

// --- I2C 설정 ---
#ifndef TWINT
#define TWINT 7
#define TWEA  6
#define TWSTA 5
#define TWSTO 4
#define TWWC  3
#define TWEN  2
#endif

#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF

// 레지스터 주소
#define REG_INTR_STATUS_1 0x00
#define REG_FIFO_WR_PTR   0x04
#define REG_FIFO_RD_PTR   0x06
#define REG_FIFO_DATA     0x07
#define REG_FIFO_CONFIG   0x08
#define REG_MODE_CONFIG   0x09
#define REG_SPO2_CONFIG   0x0A
#define REG_LED1_PA       0x0C
#define REG_LED2_PA       0x0D

// 전역 변수 (인터럽트와 공유하므로 volatile 필수)
volatile char buzzer_cmd = -1; // -1: 대기, 0: 끔, 1: 켬

// --- [개선됨] 타임아웃이 적용된 TWI 함수 ---
// 반환값: 1=성공, 0=실패(타임아웃)
unsigned char TWI_wait(void) {
    unsigned int timeout = 0;
    // 약 3ms 정도 대기 (시스템 상황에 따라 조절 가능)
    while (!(TWCR & (1 << TWINT))) {
        timeout++;
        if (timeout > 30000) return 0; // 타임아웃 발생!
    }
    return 1;
}

void TWI_init(void) {
    TWSR = 0x00; 
    TWBR = 72;   // 100kHz @ 16MHz
    TWCR = (1 << TWEN);
}

unsigned char TWI_start(void) {
    TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
    return TWI_wait();
}

void TWI_stop(void) {
    TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN);
    delay_us(100); // Stop 후 잠시 대기
}

unsigned char TWI_write(unsigned char data) {
    TWDR = data;
    TWCR = (1 << TWINT) | (1 << TWEN);
    return TWI_wait();
}

unsigned char TWI_read_ack(unsigned char *data) {
    TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
    if (!TWI_wait()) return 0;
    *data = TWDR;
    return 1;
}

unsigned char TWI_read_nack(unsigned char *data) {
    TWCR = (1 << TWINT) | (1 << TWEN);
    if (!TWI_wait()) return 0;
    *data = TWDR;
    return 1;
}

// --- MAX30102 제어 (에러 처리 추가) ---
void MAX30102_writeReg(unsigned char reg, unsigned char value) {
    if (!TWI_start()) return;
    if (!TWI_write(MAX30102_ADDR_W)) return;
    if (!TWI_write(reg)) return;
    if (!TWI_write(value)) return;
    TWI_stop();
}

unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
    if (!TWI_start()) return 0;
    if (!TWI_write(MAX30102_ADDR_W)) return 0;
    if (!TWI_write(reg)) return 0;
    if (!TWI_start()) return 0; // Repeated Start
    if (!TWI_write(MAX30102_ADDR_R)) return 0;
    if (!TWI_read_nack(result)) return 0;
    TWI_stop();
    return 1;
}

void MAX30102_init(void) {
    // 초기화 실패를 방지하기 위해 TWI 리셋
    TWI_init();
    
    MAX30102_writeReg(REG_MODE_CONFIG, 0x40); // Reset
    delay_ms(100);
    MAX30102_writeReg(REG_FIFO_CONFIG, 0x50); 
    MAX30102_writeReg(REG_MODE_CONFIG, 0x03); 
    MAX30102_writeReg(REG_SPO2_CONFIG, 0x27); 
    MAX30102_writeReg(REG_LED1_PA, 0x24);     
    MAX30102_writeReg(REG_LED2_PA, 0x24);
    
    MAX30102_writeReg(REG_FIFO_WR_PTR, 0x00);
    MAX30102_writeReg(0x05, 0x00); // Overflow Counter
    MAX30102_writeReg(REG_FIFO_RD_PTR, 0x00);
}

// --- 부저 제어 ---
void buzzer_off(void) {
    TCCR1A = 0; TCCR1B = 0;
    DDRB &= ~(1 << 5); PORTB &= ~(1 << 5);
}

void buzzer_on_2khz(void) {
    DDRB |= (1 << 5);
    TCCR1A = (1 << COM1A0);
    TCCR1B = (1 << WGM12) | (1 << CS11);
    OCR1A = 499; 
}

// --- UART ---
void UART0_init(void) {
    UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
    UCSR0C = 0x06;
    UBRR0H = 0; UBRR0L = 8; // 115200 bps
}

// [개선됨] ISR 내부 작업을 최소화하고 플래그만 세움
interrupt [USART0_RXC] void usart0_rx_isr(void) {
    char received = UDR0;
    if (received == '1') buzzer_cmd = 1;
    else if (received == '0') buzzer_cmd = 0;
}

void main(void) {
    uint32_t red_val;
    unsigned char ptr_w, ptr_r;
    unsigned char d[6];
    unsigned char success;
    int i;

    UART0_init();
    TWI_init();
    
    printf("System Start\r\n");
    MAX30102_init();
    
    #asm("sei") 

    while (1) {
        // 1. 부저 명령 처리 (Main Loop에서 안전하게 실행)
        if (buzzer_cmd != -1) {
            if (buzzer_cmd == 1) buzzer_on_2khz();
            else buzzer_off();
            buzzer_cmd = -1; // 명령 처리 완료
        }

        // 2. 데이터 읽기 (타임아웃 적용)
        success = 1;
        if (!MAX30102_readReg(REG_FIFO_WR_PTR, &ptr_w)) success = 0;
        if (success && !MAX30102_readReg(REG_FIFO_RD_PTR, &ptr_r)) success = 0;

        if (success && (ptr_w != ptr_r)) {
            // Burst Read Sequence
            if (!TWI_start()) success = 0;
            if (success && !TWI_write(MAX30102_ADDR_W)) success = 0;
            if (success && !TWI_write(REG_FIFO_DATA)) success = 0;
            if (success && !TWI_start()) success = 0;
            if (success && !TWI_write(MAX30102_ADDR_R)) success = 0;

            if (success) {
                for(i=0; i<5; i++) {
                    if (!TWI_read_ack(&d[i])) { success = 0; break; }
                }
                if (success && !TWI_read_nack(&d[5])) success = 0;
            }
            
            if (success) TWI_stop();

            // 성공했을 때만 전송
            if (success) {
                red_val = ((uint32_t)d[0] << 16 | (uint32_t)d[1] << 8 | d[2]) & 0x03FFFF;
                printf("%ld\r\n", red_val);
            }
        }

        // 3. I2C 에러 발생 시 복구
        if (!success) {
            // I2C 버스가 꼬였을 때 강제 리셋
            TWCR = 0; // TWI 끄기
            delay_ms(10);
            TWI_init(); // TWI 다시 켜기
            // 필요하다면 센서 재설정 (MAX30102_init) 도 가능하나, 보통 TWI 리셋으로 충분
        }
    }
}