#include <mega128.h>
#include <delay.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// --------------------------------------------------------------------------------
// [설정 및 매크로]
// --------------------------------------------------------------------------------
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
#define LCD_ADDR_W      (0x27 << 1) 

// LCD 비트
#define LCD_BL_ON       0x08  
#define LCD_EN          0x04  
#define LCD_RW          0x02  
#define LCD_RS          0x01  

// MAX30102 레지스터
#define REG_INTR_STATUS_1 0x00
#define REG_FIFO_WR_PTR   0x04
#define REG_FIFO_RD_PTR   0x06
#define REG_FIFO_DATA     0x07
#define REG_FIFO_CONFIG   0x08
#define REG_MODE_CONFIG   0x09
#define REG_SPO2_CONFIG   0x0A
#define REG_LED1_PA       0x0C
#define REG_LED2_PA       0x0D

#define RX_BUFFER_SIZE 20
volatile char rx_buffer[RX_BUFFER_SIZE];
volatile uint8_t rx_index = 0;
volatile uint8_t msg_ready = 0; 

// [추가됨] 부저 타이밍을 위한 전역 변수
// Timer0 오버플로우마다 증가 (약 16ms 단위)
volatile uint8_t timer_tick = 0; 

// --------------------------------------------------------------------------------
// [타이머 인터럽트] - 시스템 시간을 백그라운드에서 잰다
// --------------------------------------------------------------------------------
// Timer0 Overflow ISR: 16MHz / 1024분주 / 256count = 약 61Hz (16.3ms 주기)
interrupt [TIM0_OVF] void timer0_ovf_isr(void) {
    timer_tick++;
    // 약 1초(60 tick)가 지나면 0으로 초기화 (0 ~ 60 반복)
    if (timer_tick >= 60) {
        timer_tick = 0;
    }
}

// --------------------------------------------------------------------------------
// [기존 I2C / LCD / MAX30102 함수들 (그대로 유지)]
// --------------------------------------------------------------------------------
void TWI_init(void) {
    TWSR = 0x00; TWBR = 72; TWCR = (1 << TWEN);
}
unsigned char TWI_wait(void) {
    unsigned int timeout = 0;
    while (!(TWCR & (1 << TWINT))) {
        timeout++; if (timeout > 30000) return 0;
    } return 1;
}
unsigned char TWI_start(void) {
    TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN); return TWI_wait();
}
void TWI_stop(void) {
    TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN); delay_us(100);
}
unsigned char TWI_write(unsigned char data) {
    TWDR = data; TWCR = (1 << TWINT) | (1 << TWEN); return TWI_wait();
}
unsigned char TWI_read_ack(unsigned char *data) {
    TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
    if (!TWI_wait()) return 0; *data = TWDR; return 1;
}
unsigned char TWI_read_nack(unsigned char *data) {
    TWCR = (1 << TWINT) | (1 << TWEN);
    if (!TWI_wait()) return 0; *data = TWDR; return 1;
}

void lcd_i2c_transmit(uint8_t data) {
    if(!TWI_start()) return; if(!TWI_write(LCD_ADDR_W)) return;
    TWI_write(data); TWI_stop();
}
void lcd_send_nibble(uint8_t nibble, uint8_t mode) {
    uint8_t data = (nibble & 0xF0) | mode | LCD_BL_ON; 
    lcd_i2c_transmit(data | LCD_EN); delay_us(2);
    lcd_i2c_transmit(data & ~LCD_EN); delay_us(50); 
}
void lcd_send_byte(uint8_t val, uint8_t mode) {
    uint8_t high = val & 0xF0; uint8_t low = (val << 4) & 0xF0;
    lcd_send_nibble(high, mode); lcd_send_nibble(low, mode);
}
void lcd_command(uint8_t cmd) { lcd_send_byte(cmd, 0); }
void lcd_data(uint8_t data)   { lcd_send_byte(data, LCD_RS); }
void lcd_init(void) {
    delay_ms(50);
    lcd_send_nibble(0x30, 0); delay_ms(5);
    lcd_send_nibble(0x30, 0); delay_us(200);
    lcd_send_nibble(0x30, 0); delay_us(100);
    lcd_send_nibble(0x20, 0); delay_ms(2);
    lcd_command(0x28); lcd_command(0x0C); lcd_command(0x06); lcd_command(0x01); delay_ms(2);
}
void lcd_string(char *str) { while (*str) lcd_data(*str++); }
void lcd_gotoxy(uint8_t x, uint8_t y) {
    uint8_t addr = (y == 0) ? 0x80 : 0xC0; addr += x; lcd_command(addr);
}

void MAX30102_writeReg(unsigned char reg, unsigned char value) {
    if (!TWI_start()) return; if (!TWI_write(MAX30102_ADDR_W)) return;
    if (!TWI_write(reg)) return; if (!TWI_write(value)) return; TWI_stop();
}
unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
    if (!TWI_start()) return 0; if (!TWI_write(MAX30102_ADDR_W)) return 0;
    if (!TWI_write(reg)) return 0; if (!TWI_start()) return 0; 
    if (!TWI_write(MAX30102_ADDR_R)) return 0; if (!TWI_read_nack(result)) return 0;
    TWI_stop(); return 1;
}
void MAX30102_init(void) {
    MAX30102_writeReg(REG_MODE_CONFIG, 0x40); delay_ms(100);
    MAX30102_writeReg(REG_FIFO_CONFIG, 0x50); 
    MAX30102_writeReg(REG_MODE_CONFIG, 0x03); 
    MAX30102_writeReg(REG_SPO2_CONFIG, 0x27); 
    MAX30102_writeReg(REG_LED1_PA, 0x24); MAX30102_writeReg(REG_LED2_PA, 0x24);
    MAX30102_writeReg(REG_FIFO_WR_PTR, 0x00); MAX30102_writeReg(0x05, 0x00); 
    MAX30102_writeReg(REG_FIFO_RD_PTR, 0x00);
}

// --------------------------------------------------------------------------------
// [부저 및 UART]
// --------------------------------------------------------------------------------
void buzzer_off(void) {
    // Timer1 출력 연결 해제 및 카운터 정지
    TCCR1A = 0; TCCR1B = 0;
    DDRB &= ~(1 << 5); PORTB &= ~(1 << 5);
}

void buzzer_on_2khz(void) {
    // 이미 켜져 있다면 다시 설정하지 않음 (소리 끊김 방지)
    if (TCCR1B == 0) {
        DDRB |= (1 << 5); 
        TCCR1A = (1 << COM1A0); 
        TCCR1B = (1 << WGM12) | (1 << CS11); 
        OCR1A = 499; 
    }
}

void UART0_init(void) {
    UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
    UCSR0C = 0x06; UBRR0H = 0; UBRR0L = 8; 
}

interrupt [USART0_RXC] void usart0_rx_isr(void) {
    char received = UDR0;
    if (received == '<') { rx_index = 0; } 
    else if (received == '>') { rx_buffer[rx_index] = '\0'; msg_ready = 1; } 
    else { if (rx_index < RX_BUFFER_SIZE - 1) rx_buffer[rx_index++] = received; }
}

// --------------------------------------------------------------------------------
// [메인 함수]
// --------------------------------------------------------------------------------
void main(void) {
    uint32_t red_val;
    unsigned char ptr_w, ptr_r, d[6], success;
    int i;
    
    int pc_bpm = 0;
    char pc_status = 'N';
    char lcd_line[16];

    UART0_init();
    TWI_init();    
    MAX30102_init();
    lcd_init();

    // [추가됨] Timer0 초기화 (부저 깜빡임 타이밍용)
    // Prescaler 1024 (16MHz/1024 -> 15.625kHz), Overflow @ 256cnt -> 약 61Hz
    TCCR0 = 0x07; // CS02=1, CS01=1, CS00=1
    TIMSK |= (1 << TOIE0); // Timer0 Overflow Interrupt Enable

    printf("System Start\r\n");
    lcd_gotoxy(0, 0); lcd_string("System Ready");
    delay_ms(1000);
    lcd_command(0x01); 

    #asm("sei") 

    while (1) {
        // --- 1. PC 데이터 처리 및 부저 제어 ---
        if (msg_ready) {
            if (sscanf(rx_buffer, "%d,%c", &pc_bpm, &pc_status) == 2) {
                // LCD 갱신
                sprintf(lcd_line, "HR: %d BPM    ", pc_bpm);
                lcd_gotoxy(0, 0); lcd_string(lcd_line);

                lcd_gotoxy(0, 1);
                if (pc_status == 'N') lcd_string("Status: Normal  ");
                else if (pc_status == 'W') lcd_string("Status: WARNING!");
            }
            msg_ready = 0;
        }

        // [수정됨] 부저 비동기 제어 로직
        if (pc_status == 'W') {
            // timer_tick은 ISR에서 0~60까지 계속 돕니다 (약 1초 주기)
            // 0 ~ 30 (약 0.5초): 켜짐
            // 30 ~ 60 (약 0.5초): 꺼짐
            if (timer_tick < 30) {
                buzzer_on_2khz();
            } else {
                buzzer_off();
            }
        } else {
            // 정상이면 항상 끔
            buzzer_off();
        }

        // --- 2. 센서 데이터 읽기 (기존과 동일) ---
        success = 1;
        if (!MAX30102_readReg(REG_FIFO_WR_PTR, &ptr_w)) success = 0;
        if (success && !MAX30102_readReg(REG_FIFO_RD_PTR, &ptr_r)) success = 0;

        if (success && (ptr_w != ptr_r)) {
            if (!TWI_start()) success = 0;
            if (success && !TWI_write(MAX30102_ADDR_W)) success = 0;
            if (success && !TWI_write(REG_FIFO_DATA)) success = 0;
            if (success && !TWI_start()) success = 0;
            if (success && !TWI_write(MAX30102_ADDR_R)) success = 0;

            if (success) {
                for(i=0; i<5; i++) { if (!TWI_read_ack(&d[i])) { success = 0; break; } }
                if (success && !TWI_read_nack(&d[5])) success = 0;
            }
            if (success) TWI_stop();

            if (success) {
                red_val = ((uint32_t)d[0] << 16 | (uint32_t)d[1] << 8 | d[2]) & 0x03FFFF;
                printf("%ld\r\n", red_val);
            }
        }

        if (!success) {
            TWCR = 0; delay_ms(10); TWI_init();
        }
    }
}