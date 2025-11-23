
;CodeVisionAVR C Compiler V4.05 Evaluation
;(C) Copyright 1998-2025 Pavel Haiduc, HP InfoTech S.R.L.
;http://www.hpinfotech.ro

;Build configuration    : Debug
;Chip type              : ATmega128A
;Program type           : Application
;Clock frequency        : 16.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : long, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 1024 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Mode 2
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega128A
	#pragma AVRPART MEMORY PROG_FLASH 131072
	#pragma AVRPART MEMORY EEPROM 4096
	#pragma AVRPART MEMORY INT_SRAM SIZE 4096
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC

	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPMCSR=0x68
	.EQU RAMPZ=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.EQU __FLASH_PAGE_SIZE=0x80

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETW1P
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETD1P_INC
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X+
	.ENDM

	.MACRO __GETD1P_DEC
	LD   R23,-X
	LD   R22,-X
	LD   R31,-X
	LD   R30,-X
	.ENDM

	.MACRO __PUTDP1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTDP1_DEC
	ST   -X,R23
	ST   -X,R22
	ST   -X,R31
	ST   -X,R30
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __CPD10
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	.ENDM

	.MACRO __CPD20
	SBIW R26,0
	SBCI R24,0
	SBCI R25,0
	.ENDM

	.MACRO __ADDD12
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	.ENDM

	.MACRO __ADDD21
	ADD  R26,R30
	ADC  R27,R31
	ADC  R24,R22
	ADC  R25,R23
	.ENDM

	.MACRO __SUBD12
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	SBC  R23,R25
	.ENDM

	.MACRO __SUBD21
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R25,R23
	.ENDM

	.MACRO __ANDD12
	AND  R30,R26
	AND  R31,R27
	AND  R22,R24
	AND  R23,R25
	.ENDM

	.MACRO __ORD12
	OR   R30,R26
	OR   R31,R27
	OR   R22,R24
	OR   R23,R25
	.ENDM

	.MACRO __XORD12
	EOR  R30,R26
	EOR  R31,R27
	EOR  R22,R24
	EOR  R23,R25
	.ENDM

	.MACRO __XORD21
	EOR  R26,R30
	EOR  R27,R31
	EOR  R24,R22
	EOR  R25,R23
	.ENDM

	.MACRO __COMD1
	COM  R30
	COM  R31
	COM  R22
	COM  R23
	.ENDM

	.MACRO __MULD2_2
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	.ENDM

	.MACRO __LSRD1
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	.ENDM

	.MACRO __LSLD1
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	.ENDM

	.MACRO __ASRB4
	ASR  R30
	ASR  R30
	ASR  R30
	ASR  R30
	.ENDM

	.MACRO __ASRW8
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	.ENDM

	.MACRO __LSRD16
	MOV  R30,R22
	MOV  R31,R23
	LDI  R22,0
	LDI  R23,0
	.ENDM

	.MACRO __LSLD16
	MOV  R22,R30
	MOV  R23,R31
	LDI  R30,0
	LDI  R31,0
	.ENDM

	.MACRO __CWD1
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	.ENDM

	.MACRO __CWD2
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	.ENDM

	.MACRO __SETMSD1
	SER  R31
	SER  R22
	SER  R23
	.ENDM

	.MACRO __ADDW1R15
	CLR  R0
	ADD  R30,R15
	ADC  R31,R0
	.ENDM

	.MACRO __ADDW2R15
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	.ENDM

	.MACRO __EQB12
	CP   R30,R26
	LDI  R30,1
	BREQ PC+2
	CLR  R30
	.ENDM

	.MACRO __NEB12
	CP   R30,R26
	LDI  R30,1
	BRNE PC+2
	CLR  R30
	.ENDM

	.MACRO __LEB12
	CP   R30,R26
	LDI  R30,1
	BRGE PC+2
	CLR  R30
	.ENDM

	.MACRO __GEB12
	CP   R26,R30
	LDI  R30,1
	BRGE PC+2
	CLR  R30
	.ENDM

	.MACRO __LTB12
	CP   R26,R30
	LDI  R30,1
	BRLT PC+2
	CLR  R30
	.ENDM

	.MACRO __GTB12
	CP   R30,R26
	LDI  R30,1
	BRLT PC+2
	CLR  R30
	.ENDM

	.MACRO __LEB12U
	CP   R30,R26
	LDI  R30,1
	BRSH PC+2
	CLR  R30
	.ENDM

	.MACRO __GEB12U
	CP   R26,R30
	LDI  R30,1
	BRSH PC+2
	CLR  R30
	.ENDM

	.MACRO __LTB12U
	CP   R26,R30
	LDI  R30,1
	BRLO PC+2
	CLR  R30
	.ENDM

	.MACRO __GTB12U
	CP   R30,R26
	LDI  R30,1
	BRLO PC+2
	CLR  R30
	.ENDM

	.MACRO __CPW01
	CLR  R0
	CP   R0,R30
	CPC  R0,R31
	.ENDM

	.MACRO __CPW02
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	.ENDM

	.MACRO __CPD12
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	CPC  R23,R25
	.ENDM

	.MACRO __CPD21
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R25,R23
	.ENDM

	.MACRO __BSTB1
	CLT
	TST  R30
	BREQ PC+2
	SET
	.ENDM

	.MACRO __LNEGB1
	TST  R30
	LDI  R30,1
	BREQ PC+2
	CLR  R30
	.ENDM

	.MACRO __LNEGW1
	OR   R30,R31
	LDI  R30,1
	BREQ PC+2
	LDI  R30,0
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD2M
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CALL __GETW1Z
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CALL __GETD1Z
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __GETW2X
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __GETD2X
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart0_rx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_0x3:
	.DB  0xFF
_0x0:
	.DB  0x53,0x79,0x73,0x74,0x65,0x6D,0x20,0x53
	.DB  0x74,0x61,0x72,0x74,0xD,0xA,0x0,0x25
	.DB  0x6C,0x64,0xD,0xA,0x0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  _buzzer_cmd
	.DW  _0x3*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI

	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRB,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

	OUT  RAMPZ,R24

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0x00

	.DSEG
	.ORG 0x500

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.DSEG
;unsigned char TWI_wait(void) {
; 0000 0023 unsigned char TWI_wait(void) {

	.CSEG
_TWI_wait:
; .FSTART _TWI_wait
; 0000 0024 unsigned int timeout = 0;
; 0000 0025 // 약 3ms 정도 대기 (시스템 상황에 따라 조절 가능)
; 0000 0026 while (!(TWCR & (1 << TWINT))) {
	ST   -Y,R17
	ST   -Y,R16
;	timeout -> R16,R17
	__GETWRN 16,17,0
_0x4:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BRNE _0x6
; 0000 0027 timeout++;
	__ADDWRN 16,17,1
; 0000 0028 if (timeout > 30000) return 0; // 타임아웃 발생!
	__CPWRN 16,17,30001
	BRLO _0x7
	LDI  R30,LOW(0)
	RJMP _0x2060003
; 0000 0029 }
_0x7:
	RJMP _0x4
_0x6:
; 0000 002A return 1;
	RJMP _0x2060005
; 0000 002B }
; .FEND
;void TWI_init(void) {
; 0000 002D void TWI_init(void) {
_TWI_init:
; .FSTART _TWI_init
; 0000 002E TWSR = 0x00;
	LDI  R30,LOW(0)
	STS  113,R30
; 0000 002F TWBR = 72;   // 100kHz @ 16MHz
	LDI  R30,LOW(72)
	STS  112,R30
; 0000 0030 TWCR = (1 << TWEN);
	LDI  R30,LOW(4)
	STS  116,R30
; 0000 0031 }
	RET
; .FEND
;unsigned char TWI_start(void) {
; 0000 0033 unsigned char TWI_start(void) {
_TWI_start:
; .FSTART _TWI_start
; 0000 0034 TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN);
	LDI  R30,LOW(164)
	STS  116,R30
; 0000 0035 return TWI_wait();
	RCALL _TWI_wait
	RET
; 0000 0036 }
; .FEND
;void TWI_stop(void) {
; 0000 0038 void TWI_stop(void) {
_TWI_stop:
; .FSTART _TWI_stop
; 0000 0039 TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN);
	LDI  R30,LOW(148)
	STS  116,R30
; 0000 003A delay_us(100); // Stop 후 잠시 대기
	__DELAY_USW 400
; 0000 003B }
	RET
; .FEND
;unsigned char TWI_write(unsigned char data) {
; 0000 003D unsigned char TWI_write(unsigned char data) {
_TWI_write:
; .FSTART _TWI_write
; 0000 003E TWDR = data;
	ST   -Y,R17
	MOV  R17,R26
;	data -> R17
	STS  115,R17
; 0000 003F TWCR = (1 << TWINT) | (1 << TWEN);
	RCALL SUBOPT_0x0
; 0000 0040 return TWI_wait();
	LD   R17,Y+
	RET
; 0000 0041 }
; .FEND
;unsigned char TWI_read_ack(unsigned char *data) {
; 0000 0043 unsigned char TWI_read_ack(unsigned char *data) {
_TWI_read_ack:
; .FSTART _TWI_read_ack
; 0000 0044 TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	*data -> R16,R17
	LDI  R30,LOW(196)
	STS  116,R30
; 0000 0045 if (!TWI_wait()) return 0;
	RCALL _TWI_wait
	CPI  R30,0
	BRNE _0x8
	LDI  R30,LOW(0)
	RJMP _0x2060003
; 0000 0046 *data = TWDR;
_0x8:
	RJMP _0x2060004
; 0000 0047 return 1;
; 0000 0048 }
; .FEND
;unsigned char TWI_read_nack(unsigned char *data) {
; 0000 004A unsigned char TWI_read_nack(unsigned char *data) {
_TWI_read_nack:
; .FSTART _TWI_read_nack
; 0000 004B TWCR = (1 << TWINT) | (1 << TWEN);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	*data -> R16,R17
	RCALL SUBOPT_0x0
; 0000 004C if (!TWI_wait()) return 0;
	CPI  R30,0
	BRNE _0x9
	LDI  R30,LOW(0)
	RJMP _0x2060003
; 0000 004D *data = TWDR;
_0x9:
_0x2060004:
	LDS  R30,115
	MOVW R26,R16
	ST   X,R30
; 0000 004E return 1;
_0x2060005:
	LDI  R30,LOW(1)
_0x2060003:
	LD   R16,Y+
	LD   R17,Y+
	RET
; 0000 004F }
; .FEND
;void MAX30102_writeReg(unsigned char reg, unsigned char value) {
; 0000 0052 void MAX30102_writeReg(unsigned char reg, unsigned char value) {
_MAX30102_writeReg:
; .FSTART _MAX30102_writeReg
; 0000 0053 if (!TWI_start()) return;
	ST   -Y,R17
	ST   -Y,R16
	MOV  R17,R26
	LDD  R16,Y+2
;	reg -> R16
;	value -> R17
	RCALL _TWI_start
	CPI  R30,0
	BREQ _0x2060002
; 0000 0054 if (!TWI_write(MAX30102_ADDR_W)) return;
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x2060002
; 0000 0055 if (!TWI_write(reg)) return;
	MOV  R26,R16
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x2060002
; 0000 0056 if (!TWI_write(value)) return;
	MOV  R26,R17
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x2060002
; 0000 0057 TWI_stop();
	RCALL _TWI_stop
; 0000 0058 }
_0x2060002:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,3
	RET
; .FEND
;unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
; 0000 005A unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
_MAX30102_readReg:
; .FSTART _MAX30102_readReg
; 0000 005B if (!TWI_start()) return 0;
	RCALL __SAVELOCR4
	MOVW R16,R26
	LDD  R19,Y+4
;	reg -> R19
;	*result -> R16,R17
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0xE
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 005C if (!TWI_write(MAX30102_ADDR_W)) return 0;
_0xE:
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0xF
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 005D if (!TWI_write(reg)) return 0;
_0xF:
	MOV  R26,R19
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0x10
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 005E if (!TWI_start()) return 0; // Repeated Start
_0x10:
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0x11
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 005F if (!TWI_write(MAX30102_ADDR_R)) return 0;
_0x11:
	LDI  R26,LOW(175)
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0x12
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 0060 if (!TWI_read_nack(result)) return 0;
_0x12:
	MOVW R26,R16
	RCALL _TWI_read_nack
	CPI  R30,0
	BRNE _0x13
	LDI  R30,LOW(0)
	JMP  _0x2060001
; 0000 0061 TWI_stop();
_0x13:
	RCALL _TWI_stop
; 0000 0062 return 1;
	LDI  R30,LOW(1)
	JMP  _0x2060001
; 0000 0063 }
; .FEND
;void MAX30102_init(void) {
; 0000 0065 void MAX30102_init(void) {
_MAX30102_init:
; .FSTART _MAX30102_init
; 0000 0066 // 초기화 실패를 방지하기 위해 TWI 리셋
; 0000 0067 TWI_init();
	RCALL _TWI_init
; 0000 0068 
; 0000 0069 MAX30102_writeReg(REG_MODE_CONFIG, 0x40); // Reset
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(64)
	RCALL _MAX30102_writeReg
; 0000 006A delay_ms(100);
	LDI  R26,LOW(100)
	LDI  R27,0
	RCALL _delay_ms
; 0000 006B MAX30102_writeReg(REG_FIFO_CONFIG, 0x50);
	LDI  R30,LOW(8)
	ST   -Y,R30
	LDI  R26,LOW(80)
	RCALL _MAX30102_writeReg
; 0000 006C MAX30102_writeReg(REG_MODE_CONFIG, 0x03);
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(3)
	RCALL _MAX30102_writeReg
; 0000 006D MAX30102_writeReg(REG_SPO2_CONFIG, 0x27);
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R26,LOW(39)
	RCALL _MAX30102_writeReg
; 0000 006E MAX30102_writeReg(REG_LED1_PA, 0x24);
	LDI  R30,LOW(12)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _MAX30102_writeReg
; 0000 006F MAX30102_writeReg(REG_LED2_PA, 0x24);
	LDI  R30,LOW(13)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _MAX30102_writeReg
; 0000 0070 
; 0000 0071 MAX30102_writeReg(REG_FIFO_WR_PTR, 0x00);
	LDI  R30,LOW(4)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
; 0000 0072 MAX30102_writeReg(0x05, 0x00); // Overflow Counter
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
; 0000 0073 MAX30102_writeReg(REG_FIFO_RD_PTR, 0x00);
	LDI  R30,LOW(6)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
; 0000 0074 }
	RET
; .FEND
;void buzzer_off(void) {
; 0000 0077 void buzzer_off(void) {
_buzzer_off:
; .FSTART _buzzer_off
; 0000 0078 TCCR1A = 0; TCCR1B = 0;
	LDI  R30,LOW(0)
	OUT  0x2F,R30
	OUT  0x2E,R30
; 0000 0079 DDRB &= ~(1 << 5); PORTB &= ~(1 << 5);
	CBI  0x17,5
	CBI  0x18,5
; 0000 007A }
	RET
; .FEND
;void buzzer_on_2khz(void) {
; 0000 007C void buzzer_on_2khz(void) {
_buzzer_on_2khz:
; .FSTART _buzzer_on_2khz
; 0000 007D DDRB |= (1 << 5);
	SBI  0x17,5
; 0000 007E TCCR1A = (1 << COM1A0);
	LDI  R30,LOW(64)
	OUT  0x2F,R30
; 0000 007F TCCR1B = (1 << WGM12) | (1 << CS11);
	LDI  R30,LOW(10)
	OUT  0x2E,R30
; 0000 0080 OCR1A = 499;
	LDI  R30,LOW(499)
	LDI  R31,HIGH(499)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 0081 }
	RET
; .FEND
;void UART0_init(void) {
; 0000 0084 void UART0_init(void) {
_UART0_init:
; .FSTART _UART0_init
; 0000 0085 UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
	LDI  R30,LOW(152)
	OUT  0xA,R30
; 0000 0086 UCSR0C = 0x06;
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 0087 UBRR0H = 0; UBRR0L = 8; // 115200 bps
	LDI  R30,LOW(0)
	STS  144,R30
	LDI  R30,LOW(8)
	OUT  0x9,R30
; 0000 0088 }
	RET
; .FEND
;interrupt [19] void usart0_rx_isr(void) {
; 0000 008B interrupt [19] void usart0_rx_isr(void) {
_usart0_rx_isr:
; .FSTART _usart0_rx_isr
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 008C char received = UDR0;
; 0000 008D if (received == '1') buzzer_cmd = 1;
	ST   -Y,R17
;	received -> R17
	IN   R17,12
	CPI  R17,49
	BRNE _0x14
	LDI  R30,LOW(1)
	RJMP _0x3D
; 0000 008E else if (received == '0') buzzer_cmd = 0;
_0x14:
	CPI  R17,48
	BRNE _0x16
	LDI  R30,LOW(0)
_0x3D:
	STS  _buzzer_cmd,R30
; 0000 008F }
_0x16:
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	RETI
; .FEND
;void main(void) {
; 0000 0091 void main(void) {
_main:
; .FSTART _main
; 0000 0092 uint32_t red_val;
; 0000 0093 unsigned char ptr_w, ptr_r;
; 0000 0094 unsigned char d[6];
; 0000 0095 unsigned char success;
; 0000 0096 int i;
; 0000 0097 
; 0000 0098 UART0_init();
	SBIW R28,10
;	red_val -> Y+6
;	ptr_w -> R17
;	ptr_r -> R16
;	d -> Y+0
;	success -> R19
;	i -> R20,R21
	RCALL _UART0_init
; 0000 0099 TWI_init();
	RCALL _TWI_init
; 0000 009A 
; 0000 009B printf("System Start\r\n");
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL _printf
	ADIW R28,2
; 0000 009C MAX30102_init();
	RCALL _MAX30102_init
; 0000 009D 
; 0000 009E #asm("sei")
	SEI
; 0000 009F 
; 0000 00A0 while (1) {
_0x17:
; 0000 00A1 // 1. 부저 명령 처리 (Main Loop에서 안전하게 실행)
; 0000 00A2 if (buzzer_cmd != -1) {
	LDS  R26,_buzzer_cmd
	LDI  R30,LOW(255)
	LDI  R27,0
	SER  R31
	CP   R30,R26
	CPC  R31,R27
	BREQ _0x1A
; 0000 00A3 if (buzzer_cmd == 1) buzzer_on_2khz();
	LDS  R26,_buzzer_cmd
	CPI  R26,LOW(0x1)
	BRNE _0x1B
	RCALL _buzzer_on_2khz
; 0000 00A4 else buzzer_off();
	RJMP _0x1C
_0x1B:
	RCALL _buzzer_off
; 0000 00A5 buzzer_cmd = -1; // 명령 처리 완료
_0x1C:
	LDI  R30,LOW(255)
	STS  _buzzer_cmd,R30
; 0000 00A6 }
; 0000 00A7 
; 0000 00A8 // 2. 데이터 읽기 (타임아웃 적용)
; 0000 00A9 success = 1;
_0x1A:
	LDI  R19,LOW(1)
; 0000 00AA if (!MAX30102_readReg(REG_FIFO_WR_PTR, &ptr_w)) success = 0;
	LDI  R30,LOW(4)
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	PUSH R17
	RCALL _MAX30102_readReg
	POP  R17
	CPI  R30,0
	BRNE _0x1D
	LDI  R19,LOW(0)
; 0000 00AB if (success && !MAX30102_readReg(REG_FIFO_RD_PTR, &ptr_r)) success = 0;
_0x1D:
	CPI  R19,0
	BREQ _0x1F
	LDI  R30,LOW(6)
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	PUSH R16
	RCALL _MAX30102_readReg
	POP  R16
	CPI  R30,0
	BREQ _0x20
_0x1F:
	RJMP _0x1E
_0x20:
	LDI  R19,LOW(0)
; 0000 00AC 
; 0000 00AD if (success && (ptr_w != ptr_r)) {
_0x1E:
	CPI  R19,0
	BREQ _0x22
	CP   R16,R17
	BRNE _0x23
_0x22:
	RJMP _0x21
_0x23:
; 0000 00AE // Burst Read Sequence
; 0000 00AF if (!TWI_start()) success = 0;
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0x24
	LDI  R19,LOW(0)
; 0000 00B0 if (success && !TWI_write(MAX30102_ADDR_W)) success = 0;
_0x24:
	CPI  R19,0
	BREQ _0x26
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x27
_0x26:
	RJMP _0x25
_0x27:
	LDI  R19,LOW(0)
; 0000 00B1 if (success && !TWI_write(REG_FIFO_DATA)) success = 0;
_0x25:
	CPI  R19,0
	BREQ _0x29
	LDI  R26,LOW(7)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x2A
_0x29:
	RJMP _0x28
_0x2A:
	LDI  R19,LOW(0)
; 0000 00B2 if (success && !TWI_start()) success = 0;
_0x28:
	CPI  R19,0
	BREQ _0x2C
	RCALL _TWI_start
	CPI  R30,0
	BREQ _0x2D
_0x2C:
	RJMP _0x2B
_0x2D:
	LDI  R19,LOW(0)
; 0000 00B3 if (success && !TWI_write(MAX30102_ADDR_R)) success = 0;
_0x2B:
	CPI  R19,0
	BREQ _0x2F
	LDI  R26,LOW(175)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x30
_0x2F:
	RJMP _0x2E
_0x30:
	LDI  R19,LOW(0)
; 0000 00B4 
; 0000 00B5 if (success) {
_0x2E:
	CPI  R19,0
	BREQ _0x31
; 0000 00B6 for(i=0; i<5; i++) {
	__GETWRN 20,21,0
_0x33:
	__CPWRN 20,21,5
	BRGE _0x34
; 0000 00B7 if (!TWI_read_ack(&d[i])) { success = 0; break; }
	MOVW R26,R28
	ADD  R26,R20
	ADC  R27,R21
	RCALL _TWI_read_ack
	CPI  R30,0
	BRNE _0x35
	LDI  R19,LOW(0)
	RJMP _0x34
; 0000 00B8 }
_0x35:
	__ADDWRN 20,21,1
	RJMP _0x33
_0x34:
; 0000 00B9 if (success && !TWI_read_nack(&d[5])) success = 0;
	CPI  R19,0
	BREQ _0x37
	MOVW R26,R28
	ADIW R26,5
	RCALL _TWI_read_nack
	CPI  R30,0
	BREQ _0x38
_0x37:
	RJMP _0x36
_0x38:
	LDI  R19,LOW(0)
; 0000 00BA }
_0x36:
; 0000 00BB 
; 0000 00BC if (success) TWI_stop();
_0x31:
	CPI  R19,0
	BREQ _0x39
	RCALL _TWI_stop
; 0000 00BD 
; 0000 00BE // 성공했을 때만 전송
; 0000 00BF if (success) {
_0x39:
	CPI  R19,0
	BREQ _0x3A
; 0000 00C0 red_val = ((uint32_t)d[0] << 16 | (uint32_t)d[1] << 8 | d[2]) & 0x03FFFF;
	LD   R30,Y
	RCALL SUBOPT_0x1
	__LSLD16
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+1
	RCALL SUBOPT_0x1
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(8)
	RCALL __LSLD12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL SUBOPT_0x2
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+2
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL SUBOPT_0x2
	__ANDD1N 0x3FFFF
	__PUTD1S 6
; 0000 00C1 printf("%ld\r\n", red_val);
	__POINTW1FN _0x0,15
	ST   -Y,R31
	ST   -Y,R30
	RCALL SUBOPT_0x3
	RCALL __PUTPARD1
	LDI  R24,4
	RCALL _printf
	ADIW R28,6
; 0000 00C2 }
; 0000 00C3 }
_0x3A:
; 0000 00C4 
; 0000 00C5 // 3. I2C 에러 발생 시 복구
; 0000 00C6 if (!success) {
_0x21:
	CPI  R19,0
	BRNE _0x3B
; 0000 00C7 // I2C 버스가 꼬였을 때 강제 리셋
; 0000 00C8 TWCR = 0; // TWI 끄기
	LDI  R30,LOW(0)
	STS  116,R30
; 0000 00C9 delay_ms(10);
	LDI  R26,LOW(10)
	LDI  R27,0
	RCALL _delay_ms
; 0000 00CA TWI_init(); // TWI 다시 켜기
	RCALL _TWI_init
; 0000 00CB // 필요하다면 센서 재설정 (MAX30102_init) 도 가능하나, 보통 TWI 리셋으로 충분
; 0000 00CC }
; 0000 00CD }
_0x3B:
	RJMP _0x17
; 0000 00CE }
_0x3C:
	RJMP _0x3C
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_putchar:
; .FSTART _putchar
	ST   -Y,R26
putchar0:
     sbis usr,udre
     rjmp putchar0
     ld   r30,y
     out  udr,r30
	ADIW R28,1
	RET
; .FEND
_put_usart_G100:
; .FSTART _put_usart_G100
	RCALL __SAVELOCR4
	MOVW R16,R26
	LDD  R19,Y+4
	MOV  R26,R19
	RCALL _putchar
	MOVW R26,R16
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
_0x2060001:
	RCALL __LOADLOCR4
	ADIW R28,5
	RET
; .FEND
__print_G100:
; .FSTART __print_G100
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,11
	RCALL __SAVELOCR6
	LDI  R17,0
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x2000016:
	LDD  R30,Y+23
	LDD  R31,Y+23+1
	ADIW R30,1
	STD  Y+23,R30
	STD  Y+23+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R18,R30
	CPI  R30,0
	BRNE PC+2
	RJMP _0x2000018
	MOV  R30,R17
	CPI  R30,0
	BRNE _0x200001C
	CPI  R18,37
	BRNE _0x200001D
	LDI  R17,LOW(1)
	RJMP _0x200001E
_0x200001D:
	RCALL SUBOPT_0x4
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	RCALL SUBOPT_0x4
	RJMP _0x20000D2
_0x2000020:
	LDI  R17,LOW(2)
	LDI  R20,LOW(0)
	LDI  R16,LOW(0)
	CPI  R18,45
	BRNE _0x2000021
	LDI  R16,LOW(1)
	RJMP _0x200001B
_0x2000021:
	CPI  R18,43
	BRNE _0x2000022
	LDI  R20,LOW(43)
	RJMP _0x200001B
_0x2000022:
	CPI  R18,32
	BRNE _0x2000023
	LDI  R20,LOW(32)
	RJMP _0x200001B
_0x2000023:
	RJMP _0x2000024
_0x200001F:
	CPI  R30,LOW(0x2)
	BRNE _0x2000025
_0x2000024:
	LDI  R21,LOW(0)
	LDI  R17,LOW(3)
	CPI  R18,48
	BRNE _0x2000026
	ORI  R16,LOW(128)
	RJMP _0x200001B
_0x2000026:
	RJMP _0x2000027
_0x2000025:
	CPI  R30,LOW(0x3)
	BRNE _0x2000028
_0x2000027:
	CPI  R18,48
	BRLO _0x200002A
	CPI  R18,58
	BRLO _0x200002B
_0x200002A:
	RJMP _0x2000029
_0x200002B:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R18
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x200001B
_0x2000029:
	CPI  R18,108
	BRNE _0x200002C
	ORI  R16,LOW(2)
	LDI  R17,LOW(5)
	RJMP _0x200001B
_0x200002C:
	RJMP _0x200002D
_0x2000028:
	CPI  R30,LOW(0x5)
	BREQ PC+2
	RJMP _0x200001B
_0x200002D:
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x2000032
	RCALL SUBOPT_0x5
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	LDD  R26,Z+4
	ST   -Y,R26
	RCALL SUBOPT_0x6
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x73)
	BRNE _0x2000035
	RCALL SUBOPT_0x5
	RCALL SUBOPT_0x7
	RCALL _strlen
	MOV  R17,R30
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x70)
	BRNE _0x2000038
	RCALL SUBOPT_0x5
	RCALL SUBOPT_0x7
	RCALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000036:
	ANDI R16,LOW(127)
	LDI  R30,LOW(0)
	STD  Y+16,R30
	LDI  R19,LOW(0)
	RJMP _0x2000039
_0x2000038:
	CPI  R30,LOW(0x64)
	BREQ _0x200003C
	CPI  R30,LOW(0x69)
	BRNE _0x200003D
_0x200003C:
	ORI  R16,LOW(4)
	RJMP _0x200003E
_0x200003D:
	CPI  R30,LOW(0x75)
	BRNE _0x200003F
_0x200003E:
	LDI  R30,LOW(10)
	STD  Y+16,R30
	SBRS R16,1
	RJMP _0x2000040
	__GETD1N 0x3B9ACA00
	RCALL SUBOPT_0x8
	LDI  R17,LOW(10)
	RJMP _0x2000041
_0x2000040:
	__GETD1N 0x2710
	RCALL SUBOPT_0x8
	LDI  R17,LOW(5)
	RJMP _0x2000041
_0x200003F:
	CPI  R30,LOW(0x58)
	BRNE _0x2000043
	ORI  R16,LOW(8)
	RJMP _0x2000044
_0x2000043:
	CPI  R30,LOW(0x78)
	BREQ PC+2
	RJMP _0x2000077
_0x2000044:
	LDI  R30,LOW(16)
	STD  Y+16,R30
	SBRS R16,1
	RJMP _0x2000046
	__GETD1N 0x10000000
	RCALL SUBOPT_0x8
	LDI  R17,LOW(8)
	RJMP _0x2000041
_0x2000046:
	__GETD1N 0x1000
	RCALL SUBOPT_0x8
	LDI  R17,LOW(4)
_0x2000041:
	SBRS R16,1
	RJMP _0x2000047
	RCALL SUBOPT_0x5
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,4
	RCALL __GETD1P
	RJMP _0x20000D3
_0x2000047:
	SBRS R16,2
	RJMP _0x2000049
	RCALL SUBOPT_0x5
	RCALL SUBOPT_0x9
	__CWD1
	RJMP _0x20000D3
_0x2000049:
	RCALL SUBOPT_0x5
	RCALL SUBOPT_0x9
	CLR  R22
	CLR  R23
_0x20000D3:
	__PUTD1S 12
	SBRS R16,2
	RJMP _0x200004B
	LDD  R26,Y+15
	TST  R26
	BRPL _0x200004C
	__GETD1S 12
	RCALL __ANEGD1
	RCALL SUBOPT_0xA
	LDI  R20,LOW(45)
_0x200004C:
	CPI  R20,0
	BREQ _0x200004D
	SUBI R17,-LOW(1)
	RJMP _0x200004E
_0x200004D:
	ANDI R16,LOW(251)
_0x200004E:
_0x200004B:
_0x2000039:
	SBRC R16,0
	RJMP _0x200004F
_0x2000050:
	CP   R17,R21
	BRSH _0x2000052
	SBRS R16,7
	RJMP _0x2000053
	SBRS R16,2
	RJMP _0x2000054
	ANDI R16,LOW(251)
	MOV  R18,R20
	SUBI R17,LOW(1)
	RJMP _0x2000055
_0x2000054:
	LDI  R18,LOW(48)
_0x2000055:
	RJMP _0x2000056
_0x2000053:
	LDI  R18,LOW(32)
_0x2000056:
	RCALL SUBOPT_0x4
	SUBI R21,LOW(1)
	RJMP _0x2000050
_0x2000052:
_0x200004F:
	MOV  R19,R17
	LDD  R30,Y+16
	CPI  R30,0
	BRNE _0x2000057
_0x2000058:
	CPI  R19,0
	BREQ _0x200005A
	SBRS R16,3
	RJMP _0x200005B
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R18,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x200005C
_0x200005B:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R18,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x200005C:
	RCALL SUBOPT_0x4
	CPI  R21,0
	BREQ _0x200005D
	SUBI R21,LOW(1)
_0x200005D:
	SUBI R19,LOW(1)
	RJMP _0x2000058
_0x200005A:
	RJMP _0x200005E
_0x2000057:
_0x2000060:
	RCALL SUBOPT_0xB
	RCALL __DIVD21U
	MOV  R18,R30
	CPI  R18,10
	BRLO _0x2000062
	SBRS R16,3
	RJMP _0x2000063
	SUBI R18,-LOW(55)
	RJMP _0x2000064
_0x2000063:
	SUBI R18,-LOW(87)
_0x2000064:
	RJMP _0x2000065
_0x2000062:
	SUBI R18,-LOW(48)
_0x2000065:
	SBRC R16,4
	RJMP _0x2000067
	CPI  R18,49
	BRSH _0x2000069
	RCALL SUBOPT_0xC
	__CPD2N 0x1
	BRNE _0x2000068
_0x2000069:
	RJMP _0x200006B
_0x2000068:
	CP   R21,R19
	BRLO _0x200006D
	SBRS R16,0
	RJMP _0x200006E
_0x200006D:
	RJMP _0x200006C
_0x200006E:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x200006F
	LDI  R18,LOW(48)
_0x200006B:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x2000070
	ANDI R16,LOW(251)
	ST   -Y,R20
	RCALL SUBOPT_0x6
	CPI  R21,0
	BREQ _0x2000071
	SUBI R21,LOW(1)
_0x2000071:
_0x2000070:
_0x200006F:
_0x2000067:
	RCALL SUBOPT_0x4
	CPI  R21,0
	BREQ _0x2000072
	SUBI R21,LOW(1)
_0x2000072:
_0x200006C:
	SUBI R19,LOW(1)
	RCALL SUBOPT_0xB
	RCALL __MODD21U
	RCALL SUBOPT_0xA
	LDD  R30,Y+16
	RCALL SUBOPT_0xC
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL __DIVD21U
	RCALL SUBOPT_0x8
	RCALL SUBOPT_0x3
	__CPD10
	BREQ _0x2000061
	RJMP _0x2000060
_0x2000061:
_0x200005E:
	SBRS R16,0
	RJMP _0x2000073
_0x2000074:
	CPI  R21,0
	BREQ _0x2000076
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	RCALL SUBOPT_0x6
	RJMP _0x2000074
_0x2000076:
_0x2000073:
_0x2000077:
_0x2000033:
_0x20000D2:
	LDI  R17,LOW(0)
_0x200001B:
	RJMP _0x2000016
_0x2000018:
	LDD  R26,Y+17
	LDD  R27,Y+17+1
	LD   R30,X+
	LD   R31,X+
	RCALL __LOADLOCR6
	ADIW R28,25
	RET
; .FEND
_printf:
; .FSTART _printf
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	ST   -Y,R17
	ST   -Y,R16
	MOVW R26,R28
	ADIW R26,4
	__ADDW2R15
	MOVW R16,R26
	LDI  R30,LOW(0)
	STD  Y+4,R30
	STD  Y+4+1,R30
	STD  Y+6,R30
	STD  Y+6+1,R30
	MOVW R26,R28
	ADIW R26,8
	__ADDW2R15
	LD   R30,X+
	LD   R31,X+
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_usart_G100)
	LDI  R31,HIGH(_put_usart_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,8
	RCALL __print_G100
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,8
	POP  R15
	RET
; .FEND

	.CSEG

	.CSEG
_strlen:
; .FSTART _strlen
	ST   -Y,R27
	ST   -Y,R26
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
; .FEND
_strlenf:
; .FSTART _strlenf
	ST   -Y,R27
	ST   -Y,R26
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret
; .FEND

	.DSEG
_buzzer_cmd:
	.BYTE 0x1

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	LDI  R30,LOW(132)
	STS  116,R30
	RJMP _TWI_wait

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x1:
	LDI  R31,0
	__CWD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2:
	__ORD12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x3:
	__GETD1S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x4:
	ST   -Y,R18
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x5:
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	SBIW R30,4
	STD  Y+21,R30
	STD  Y+21+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x6:
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x7:
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,4
	LD   R30,X+
	LD   R31,X+
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x8:
	__PUTD1S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x9:
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,4
	__GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xA:
	__PUTD1S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0xB:
	RCALL SUBOPT_0x3
	__GETD2S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xC:
	__GETD2S 8
	RET

;RUNTIME LIBRARY

	.CSEG
__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__LSLD12:
	TST  R30
	MOV  R0,R30
	LDI  R30,8
	MOV  R1,R30
	MOVW R30,R26
	MOVW R22,R24
	BREQ __LSLD12R
__LSLD12S8:
	CP   R0,R1
	BRLO __LSLD12L
	MOV  R23,R22
	MOV  R22,R31
	MOV  R31,R30
	LDI  R30,0
	SUB  R0,R1
	BRNE __LSLD12S8
	RET
__LSLD12L:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R0
	BRNE __LSLD12L
__LSLD12R:
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	MOVW R20,R0
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__MODD21U:
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	RET

__GETD1P:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X
	SBIW R26,3
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	wdr
	__DELAY_USW 0xFA0
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

;END OF CODE MARKER
__END_OF_CODE:
