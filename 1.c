/*
 * MAX30102_Connection_Test.c
 * Compiler: CodeVisionAVR
 * Target: ATmega128
 * Frequency: 16MHz
 */

#include <mega128a.h>
#include <delay.h>
#include <stdio.h>
#include <stdint.h> // uint8_t 사용을 위해 필요

// --- MAX30102 I2C Address ---
#define MAX30102_ADDR_W 0xAE
#define MAX30102_ADDR_R 0xAF
#define REG_PART_ID     0xFF

// --- UART 초기화 ---
void UART0_init(void) {
    UBRR0H = 0;
    UBRR0L = 103; // 9600bps @ 16MHz
    UCSR0B = (1 << RXEN0) | (1 << TXEN0); // 수신, 송신 활성화
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit data, No parity, 1 stop bit
}


#define putchar putchar_arv

// --- CodeVisionAVR에서 printf를 쓰기 위한 필수 함수 ---
// 이 함수를 정의하면 printf가 내부적으로 이 함수를 호출합니다.
void putchar_arv(char c) {
    while (!(UCSR0A & (1 << UDRE0))); // 송신 버퍼 빌 때까지 대기
    UDR0 = c;
}

// --- I2C (TWI) 기능 ---
void TWI_init(void) {
    // 100kHz @ 16MHz
    TWSR = 0x00; // Prescaler = 1
    TWBR = 72;   
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

uint8_t TWI_read_nack(void) {
    // 마지막 바이트 수신 후 NACK 전송
    TWCR = (1 << TWINT) | (1 << TWEN);
    while (!(TWCR & (1 << TWINT)));
    return TWDR;
}

// --- MAX30102 Part ID 읽기 ---
uint8_t MAX30102_ReadPartID() {
    uint8_t part_id;

    TWI_start();
    TWI_write(MAX30102_ADDR_W);
    TWI_write(REG_PART_ID);
    
    TWI_start(); // Repeated Start
    TWI_write(MAX30102_ADDR_R);
    
    part_id = TWI_read_nack();
    TWI_stop();

    return part_id;
}

void main(void) {
    uint8_t id;

    // 초기화
    UART0_init();
    TWI_init();
    
    // CodeVisionAVR에서는 전역 인터럽트 활성화가 필요한 경우가 있음 (I2C 라이브러리 사용 시)
    // 직접 제어 방식이므로 여기선 필수 아님
    
    delay_ms(1000); // 안정화 대기
    
    printf("System Start\r\n"); // \n 대신 \r\n 권장 (터미널 줄바꿈 호환성)
    printf("Checking MAX30102 Connection...\r\n");

    while (1) {
        id = MAX30102_ReadPartID();
        
        printf("Read Part ID: 0x%02X ", id);

        if (id == 0x15) {
            printf("(Success!)\r\n");
        } else {
            printf("(Fail - Check Wiring)\r\n");
        }

        delay_ms(1000);
    }
}