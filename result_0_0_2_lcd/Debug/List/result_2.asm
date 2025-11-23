
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
	JMP  _timer0_ovf_isr
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

_0x0:
	.DB  0x53,0x79,0x73,0x74,0x65,0x6D,0x20,0x53
	.DB  0x74,0x61,0x72,0x74,0xD,0xA,0x0,0x53
	.DB  0x79,0x73,0x74,0x65,0x6D,0x20,0x52,0x65
	.DB  0x61,0x64,0x79,0x0,0x25,0x64,0x2C,0x25
	.DB  0x63,0x0,0x48,0x52,0x3A,0x20,0x25,0x64
	.DB  0x20,0x42,0x50,0x4D,0x20,0x20,0x20,0x20
	.DB  0x0,0x53,0x74,0x61,0x74,0x75,0x73,0x3A
	.DB  0x20,0x4E,0x6F,0x72,0x6D,0x61,0x6C,0x20
	.DB  0x20,0x0,0x53,0x74,0x61,0x74,0x75,0x73
	.DB  0x3A,0x20,0x57,0x41,0x52,0x4E,0x49,0x4E
	.DB  0x47,0x21,0x0,0x25,0x6C,0x64,0xD,0xA
	.DB  0x0
_0x2020060:
	.DB  0x1
_0x2020000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x0D
	.DW  _0x22
	.DW  _0x0*2+15

	.DW  0x11
	.DW  _0x22+13
	.DW  _0x0*2+49

	.DW  0x11
	.DW  _0x22+30
	.DW  _0x0*2+66

	.DW  0x01
	.DW  __seed_G101
	.DW  _0x2020060*2

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
;interrupt [17] void timer0_ovf_isr(void) {
; 0000 0036 interrupt [17] void timer0_ovf_isr(void) {

	.CSEG
_timer0_ovf_isr:
; .FSTART _timer0_ovf_isr
	ST   -Y,R26
	ST   -Y,R30
	IN   R30,SREG
	ST   -Y,R30
; 0000 0037 timer_tick++;
	LDS  R30,_timer_tick
	SUBI R30,-LOW(1)
	STS  _timer_tick,R30
; 0000 0038 // 약 1초(60 tick)가 지나면 0으로 초기화 (0 ~ 60 반복)
; 0000 0039 if (timer_tick >= 60) {
	LDS  R26,_timer_tick
	CPI  R26,LOW(0x3C)
	BRLO _0x3
; 0000 003A timer_tick = 0;
	LDI  R30,LOW(0)
	STS  _timer_tick,R30
; 0000 003B }
; 0000 003C }
_0x3:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;void TWI_init(void) {
; 0000 0041 void TWI_init(void) {
_TWI_init:
; .FSTART _TWI_init
; 0000 0042 TWSR = 0x00; TWBR = 72; TWCR = (1 << TWEN);
	LDI  R30,LOW(0)
	STS  113,R30
	LDI  R30,LOW(72)
	STS  112,R30
	LDI  R30,LOW(4)
	STS  116,R30
; 0000 0043 }
	RET
; .FEND
;unsigned char TWI_wait(void) {
; 0000 0044 unsigned char TWI_wait(void) {
_TWI_wait:
; .FSTART _TWI_wait
; 0000 0045 unsigned int timeout = 0;
; 0000 0046 while (!(TWCR & (1 << TWINT))) {
	ST   -Y,R17
	ST   -Y,R16
;	timeout -> R16,R17
	__GETWRN 16,17,0
_0x4:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BRNE _0x6
; 0000 0047 timeout++; if (timeout > 30000) return 0;
	__ADDWRN 16,17,1
	__CPWRN 16,17,30001
	BRLO _0x7
	LDI  R30,LOW(0)
	RJMP _0x20A0008
; 0000 0048 } return 1;
_0x7:
	RJMP _0x4
_0x6:
	LDI  R30,LOW(1)
	RJMP _0x20A0008
; 0000 0049 }
; .FEND
;unsigned char TWI_start(void) {
; 0000 004A unsigned char TWI_start(void) {
_TWI_start:
; .FSTART _TWI_start
; 0000 004B TWCR = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN); return TWI_wait();
	LDI  R30,LOW(164)
	STS  116,R30
	RCALL _TWI_wait
	RET
; 0000 004C }
; .FEND
;void TWI_stop(void) {
; 0000 004D void TWI_stop(void) {
_TWI_stop:
; .FSTART _TWI_stop
; 0000 004E TWCR = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN); delay_us(100);
	LDI  R30,LOW(148)
	STS  116,R30
	RCALL SUBOPT_0x0
; 0000 004F }
	RET
; .FEND
;unsigned char TWI_write(unsigned char data) {
; 0000 0050 unsigned char TWI_write(unsigned char data) {
_TWI_write:
; .FSTART _TWI_write
; 0000 0051 TWDR = data; TWCR = (1 << TWINT) | (1 << TWEN); return TWI_wait();
	ST   -Y,R17
	MOV  R17,R26
;	data -> R17
	STS  115,R17
	RCALL SUBOPT_0x1
	RJMP _0x20A000A
; 0000 0052 }
; .FEND
;unsigned char TWI_read_ack(unsigned char *data) {
; 0000 0053 unsigned char TWI_read_ack(unsigned char *data) {
_TWI_read_ack:
; .FSTART _TWI_read_ack
; 0000 0054 TWCR = (1 << TWINT) | (1 << TWEN) | (1 << TWEA);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	*data -> R16,R17
	LDI  R30,LOW(196)
	STS  116,R30
; 0000 0055 if (!TWI_wait()) return 0; *data = TWDR; return 1;
	RCALL _TWI_wait
	CPI  R30,0
	BRNE _0x8
	LDI  R30,LOW(0)
	RJMP _0x20A0008
_0x8:
	RCALL SUBOPT_0x2
	RJMP _0x20A0008
; 0000 0056 }
; .FEND
;unsigned char TWI_read_nack(unsigned char *data) {
; 0000 0057 unsigned char TWI_read_nack(unsigned char *data) {
_TWI_read_nack:
; .FSTART _TWI_read_nack
; 0000 0058 TWCR = (1 << TWINT) | (1 << TWEN);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	*data -> R16,R17
	RCALL SUBOPT_0x1
; 0000 0059 if (!TWI_wait()) return 0; *data = TWDR; return 1;
	CPI  R30,0
	BRNE _0x9
	LDI  R30,LOW(0)
	RJMP _0x20A0008
_0x9:
	RCALL SUBOPT_0x2
	RJMP _0x20A0008
; 0000 005A }
; .FEND
;void lcd_i2c_transmit(uint8_t data) {
; 0000 005C void lcd_i2c_transmit(uint8_t data) {
_lcd_i2c_transmit:
; .FSTART _lcd_i2c_transmit
; 0000 005D if(!TWI_start()) return; if(!TWI_write(LCD_ADDR_W)) return;
	ST   -Y,R17
	MOV  R17,R26
;	data -> R17
	RCALL _TWI_start
	CPI  R30,0
	BREQ _0x20A000A
	LDI  R26,LOW(78)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x20A000A
; 0000 005E TWI_write(data); TWI_stop();
	MOV  R26,R17
	RCALL _TWI_write
	RCALL _TWI_stop
; 0000 005F }
	RJMP _0x20A000A
; .FEND
;void lcd_send_nibble(uint8_t nibble, uint8_t mode) {
; 0000 0060 void lcd_send_nibble(uint8_t nibble, uint8_t mode) {
_lcd_send_nibble:
; .FSTART _lcd_send_nibble
; 0000 0061 uint8_t data = (nibble & 0xF0) | mode | LCD_BL_ON;
; 0000 0062 lcd_i2c_transmit(data | LCD_EN); delay_us(2);
	RCALL SUBOPT_0x3
;	nibble -> R16
;	mode -> Y+2
;	data -> R17
	LDD  R30,Y+3
	ANDI R30,LOW(0xF0)
	LDD  R26,Y+2
	OR   R30,R26
	ORI  R30,8
	MOV  R17,R30
	ORI  R30,4
	MOV  R26,R30
	RCALL _lcd_i2c_transmit
	__DELAY_USB 11
; 0000 0063 lcd_i2c_transmit(data & ~LCD_EN); delay_us(50);
	MOV  R30,R17
	ANDI R30,0xFB
	MOV  R26,R30
	RCALL _lcd_i2c_transmit
	__DELAY_USW 200
; 0000 0064 }
	RJMP _0x20A0007
; .FEND
;void lcd_send_byte(uint8_t val, uint8_t mode) {
; 0000 0065 void lcd_send_byte(uint8_t val, uint8_t mode) {
_lcd_send_byte:
; .FSTART _lcd_send_byte
; 0000 0066 uint8_t high = val & 0xF0; uint8_t low = (val << 4) & 0xF0;
; 0000 0067 lcd_send_nibble(high, mode); lcd_send_nibble(low, mode);
	ST   -Y,R26
	RCALL __SAVELOCR4
	LDD  R19,Y+5
;	val -> R19
;	mode -> Y+4
;	high -> R17
;	low -> R16
	LDD  R30,Y+5
	ANDI R30,LOW(0xF0)
	MOV  R17,R30
	LDD  R30,Y+5
	SWAP R30
	ANDI R30,LOW(0xF0)
	MOV  R16,R30
	ST   -Y,R17
	LDD  R26,Y+5
	RCALL _lcd_send_nibble
	ST   -Y,R16
	LDD  R26,Y+5
	RCALL _lcd_send_nibble
; 0000 0068 }
	RCALL __LOADLOCR4
	ADIW R28,6
	RET
; .FEND
;void lcd_command(uint8_t cmd) { lcd_send_byte(cmd, 0); }
; 0000 0069 void lcd_command(uint8_t cmd) { lcd_send_byte(cmd, 0); }
_lcd_command:
; .FSTART _lcd_command
	ST   -Y,R17
	MOV  R17,R26
;	cmd -> R17
	ST   -Y,R17
	LDI  R26,LOW(0)
	RJMP _0x20A0009
; .FEND
;void lcd_data(uint8_t data)   { lcd_send_byte(data, 0x01); }
; 0000 006A void lcd_data(uint8_t data)   { lcd_send_byte(data, 0x01); }
_lcd_data:
; .FSTART _lcd_data
	ST   -Y,R17
	MOV  R17,R26
;	data -> R17
	ST   -Y,R17
	LDI  R26,LOW(1)
_0x20A0009:
	RCALL _lcd_send_byte
_0x20A000A:
	LD   R17,Y+
	RET
; .FEND
;void lcd_init(void) {
; 0000 006B void lcd_init(void) {
_lcd_init:
; .FSTART _lcd_init
; 0000 006C delay_ms(50);
	LDI  R26,LOW(50)
	RCALL SUBOPT_0x4
; 0000 006D lcd_send_nibble(0x30, 0); delay_ms(5);
	LDI  R26,LOW(5)
	RCALL SUBOPT_0x4
; 0000 006E lcd_send_nibble(0x30, 0); delay_us(200);
	__DELAY_USW 800
; 0000 006F lcd_send_nibble(0x30, 0); delay_us(100);
	LDI  R30,LOW(48)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _lcd_send_nibble
	RCALL SUBOPT_0x0
; 0000 0070 lcd_send_nibble(0x20, 0); delay_ms(2);
	LDI  R30,LOW(32)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _lcd_send_nibble
	LDI  R26,LOW(2)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0071 lcd_command(0x28); lcd_command(0x0C); lcd_command(0x06); lcd_command(0x01); delay_ms(2);
	LDI  R26,LOW(40)
	RCALL _lcd_command
	LDI  R26,LOW(12)
	RCALL _lcd_command
	LDI  R26,LOW(6)
	RCALL _lcd_command
	LDI  R26,LOW(1)
	RCALL _lcd_command
	LDI  R26,LOW(2)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0072 }
	RET
; .FEND
;void lcd_string(char *str) { while (*str) lcd_data(*str++); }
; 0000 0073 void lcd_string(char *str) { while (*str) lcd_data(*str++); }
_lcd_string:
; .FSTART _lcd_string
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	*str -> R16,R17
_0xC:
	MOVW R26,R16
	LD   R30,X
	CPI  R30,0
	BREQ _0xE
	__ADDWRN 16,17,1
	LD   R26,X
	RCALL _lcd_data
	RJMP _0xC
_0xE:
_0x20A0008:
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;void lcd_gotoxy(uint8_t x, uint8_t y) {
; 0000 0074 void lcd_gotoxy(uint8_t x, uint8_t y) {
_lcd_gotoxy:
; .FSTART _lcd_gotoxy
; 0000 0075 uint8_t addr = (y == 0) ? 0x80 : 0xC0; addr += x; lcd_command(addr);
	RCALL SUBOPT_0x3
;	x -> R16
;	y -> Y+2
;	addr -> R17
	LDD  R26,Y+2
	CPI  R26,LOW(0x0)
	BRNE _0xF
	LDI  R30,LOW(128)
	RJMP _0x10
_0xF:
	LDI  R30,LOW(192)
_0x10:
	MOV  R17,R30
	ADD  R17,R16
	MOV  R26,R17
	RCALL _lcd_command
; 0000 0076 }
_0x20A0007:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,4
	RET
; .FEND
;void MAX30102_writeReg(unsigned char reg, unsigned char value) {
; 0000 0078 void MAX30102_writeReg(unsigned char reg, unsigned char value) {
_MAX30102_writeReg:
; .FSTART _MAX30102_writeReg
; 0000 0079 if (!TWI_start()) return; if (!TWI_write(MAX30102_ADDR_W)) return;
	ST   -Y,R17
	ST   -Y,R16
	MOV  R17,R26
	LDD  R16,Y+2
;	reg -> R16
;	value -> R17
	RCALL _TWI_start
	CPI  R30,0
	BREQ _0x20A0006
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x20A0006
; 0000 007A if (!TWI_write(reg)) return; if (!TWI_write(value)) return; TWI_stop();
	MOV  R26,R16
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x20A0006
	MOV  R26,R17
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x20A0006
	RCALL _TWI_stop
; 0000 007B }
_0x20A0006:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,3
	RET
; .FEND
;unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
; 0000 007C unsigned char MAX30102_readReg(unsigned char reg, unsigned char *result) {
_MAX30102_readReg:
; .FSTART _MAX30102_readReg
; 0000 007D if (!TWI_start()) return 0; if (!TWI_write(MAX30102_ADDR_W)) return 0;
	RCALL __SAVELOCR4
	MOVW R16,R26
	LDD  R19,Y+4
;	reg -> R19
;	*result -> R16,R17
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0x16
	LDI  R30,LOW(0)
	JMP  _0x20A0005
_0x16:
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0x17
	LDI  R30,LOW(0)
	JMP  _0x20A0005
; 0000 007E if (!TWI_write(reg)) return 0; if (!TWI_start()) return 0;
_0x17:
	MOV  R26,R19
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0x18
	LDI  R30,LOW(0)
	JMP  _0x20A0005
_0x18:
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0x19
	LDI  R30,LOW(0)
	JMP  _0x20A0005
; 0000 007F if (!TWI_write(MAX30102_ADDR_R)) return 0; if (!TWI_read_nack(result)) return 0;
_0x19:
	LDI  R26,LOW(175)
	RCALL _TWI_write
	CPI  R30,0
	BRNE _0x1A
	LDI  R30,LOW(0)
	JMP  _0x20A0005
_0x1A:
	MOVW R26,R16
	RCALL _TWI_read_nack
	CPI  R30,0
	BRNE _0x1B
	LDI  R30,LOW(0)
	JMP  _0x20A0005
; 0000 0080 TWI_stop(); return 1;
_0x1B:
	RCALL _TWI_stop
	LDI  R30,LOW(1)
	JMP  _0x20A0005
; 0000 0081 }
; .FEND
;void MAX30102_init(void) {
; 0000 0082 void MAX30102_init(void) {
_MAX30102_init:
; .FSTART _MAX30102_init
; 0000 0083 MAX30102_writeReg(REG_MODE_CONFIG, 0x40); delay_ms(100);
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(64)
	RCALL _MAX30102_writeReg
	LDI  R26,LOW(100)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0084 MAX30102_writeReg(REG_FIFO_CONFIG, 0x50);
	LDI  R30,LOW(8)
	ST   -Y,R30
	LDI  R26,LOW(80)
	RCALL _MAX30102_writeReg
; 0000 0085 MAX30102_writeReg(REG_MODE_CONFIG, 0x03);
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(3)
	RCALL _MAX30102_writeReg
; 0000 0086 MAX30102_writeReg(REG_SPO2_CONFIG, 0x27);
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R26,LOW(39)
	RCALL _MAX30102_writeReg
; 0000 0087 MAX30102_writeReg(REG_LED1_PA, 0x24); MAX30102_writeReg(REG_LED2_PA, 0x24);
	LDI  R30,LOW(12)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _MAX30102_writeReg
	LDI  R30,LOW(13)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _MAX30102_writeReg
; 0000 0088 MAX30102_writeReg(REG_FIFO_WR_PTR, 0x00); MAX30102_writeReg(0x05, 0x00);
	LDI  R30,LOW(4)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
	LDI  R30,LOW(5)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
; 0000 0089 MAX30102_writeReg(REG_FIFO_RD_PTR, 0x00);
	LDI  R30,LOW(6)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RCALL _MAX30102_writeReg
; 0000 008A }
	RET
; .FEND
;void buzzer_off(void) {
; 0000 008F void buzzer_off(void) {
_buzzer_off:
; .FSTART _buzzer_off
; 0000 0090 // Timer1 출력 연결 해제 및 카운터 정지
; 0000 0091 TCCR1A = 0; TCCR1B = 0;
	LDI  R30,LOW(0)
	OUT  0x2F,R30
	OUT  0x2E,R30
; 0000 0092 DDRB &= ~(1 << 5); PORTB &= ~(1 << 5);
	CBI  0x17,5
	CBI  0x18,5
; 0000 0093 }
	RET
; .FEND
;void buzzer_on_2khz(void) {
; 0000 0095 void buzzer_on_2khz(void) {
_buzzer_on_2khz:
; .FSTART _buzzer_on_2khz
; 0000 0096 // 이미 켜져 있다면 다시 설정하지 않음 (소리 끊김 방지)
; 0000 0097 if (TCCR1B == 0) {
	IN   R30,0x2E
	CPI  R30,0
	BRNE _0x1C
; 0000 0098 DDRB |= (1 << 5);
	SBI  0x17,5
; 0000 0099 TCCR1A = (1 << COM1A0);
	LDI  R30,LOW(64)
	OUT  0x2F,R30
; 0000 009A TCCR1B = (1 << WGM12) | (1 << CS11);
	LDI  R30,LOW(10)
	OUT  0x2E,R30
; 0000 009B OCR1A = 499;
	LDI  R30,LOW(499)
	LDI  R31,HIGH(499)
	OUT  0x2A+1,R31
	OUT  0x2A,R30
; 0000 009C }
; 0000 009D }
_0x1C:
	RET
; .FEND
;void UART0_init(void) {
; 0000 009F void UART0_init(void) {
_UART0_init:
; .FSTART _UART0_init
; 0000 00A0 UCSR0B = (1<<RXCIE0) | (1<<RXEN0) | (1<<TXEN0);
	LDI  R30,LOW(152)
	OUT  0xA,R30
; 0000 00A1 UCSR0C = 0x06; UBRR0H = 0; UBRR0L = 8;
	LDI  R30,LOW(6)
	STS  149,R30
	LDI  R30,LOW(0)
	STS  144,R30
	LDI  R30,LOW(8)
	OUT  0x9,R30
; 0000 00A2 }
	RET
; .FEND
;interrupt [19] void usart0_rx_isr(void) {
; 0000 00A4 interrupt [19] void usart0_rx_isr(void) {
_usart0_rx_isr:
; .FSTART _usart0_rx_isr
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 00A5 char received = UDR0;
; 0000 00A6 if (received == '<') { rx_index = 0; }
	ST   -Y,R17
;	received -> R17
	IN   R17,12
	CPI  R17,60
	BRNE _0x1D
	LDI  R30,LOW(0)
	STS  _rx_index,R30
; 0000 00A7 else if (received == '>') { rx_buffer[rx_index] = '\0'; msg_ready = 1; }
	RJMP _0x1E
_0x1D:
	CPI  R17,62
	BRNE _0x1F
	LDS  R30,_rx_index
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer)
	SBCI R31,HIGH(-_rx_buffer)
	LDI  R26,LOW(0)
	STD  Z+0,R26
	LDI  R30,LOW(1)
	STS  _msg_ready,R30
; 0000 00A8 else { if (rx_index < RX_BUFFER_SIZE - 1) rx_buffer[rx_index++] = received; }
	RJMP _0x20
_0x1F:
	LDS  R26,_rx_index
	CPI  R26,LOW(0x13)
	BRSH _0x21
	LDS  R30,_rx_index
	SUBI R30,-LOW(1)
	STS  _rx_index,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer)
	SBCI R31,HIGH(-_rx_buffer)
	ST   Z,R17
_0x21:
_0x20:
_0x1E:
; 0000 00A9 }
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;void main(void) {
; 0000 00AE void main(void) {
_main:
; .FSTART _main
; 0000 00AF uint32_t red_val;
; 0000 00B0 unsigned char ptr_w, ptr_r, d[6], success;
; 0000 00B1 int i;
; 0000 00B2 
; 0000 00B3 int pc_bpm = 0;
; 0000 00B4 char pc_status = 'N';
; 0000 00B5 char lcd_line[16];
; 0000 00B6 
; 0000 00B7 UART0_init();
	SBIW R28,28
	LDI  R30,LOW(0)
	STD  Y+16,R30
	STD  Y+17,R30
;	red_val -> Y+24
;	ptr_w -> R17
;	ptr_r -> R16
;	d -> Y+18
;	success -> R19
;	i -> R20,R21
;	pc_bpm -> Y+16
;	pc_status -> R18
;	lcd_line -> Y+0
	LDI  R18,78
	RCALL _UART0_init
; 0000 00B8 TWI_init();
	RCALL _TWI_init
; 0000 00B9 MAX30102_init();
	RCALL _MAX30102_init
; 0000 00BA lcd_init();
	RCALL _lcd_init
; 0000 00BB 
; 0000 00BC // [추가됨] Timer0 초기화 (부저 깜빡임 타이밍용)
; 0000 00BD // Prescaler 1024 (16MHz/1024 -> 15.625kHz), Overflow @ 256cnt -> 약 61Hz
; 0000 00BE TCCR0 = 0x07; // CS02=1, CS01=1, CS00=1
	LDI  R30,LOW(7)
	OUT  0x33,R30
; 0000 00BF TIMSK |= (1 << TOIE0); // Timer0 Overflow Interrupt Enable
	IN   R30,0x37
	ORI  R30,1
	OUT  0x37,R30
; 0000 00C0 
; 0000 00C1 printf("System Start\r\n");
	__POINTW1FN _0x0,0
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL _printf
	ADIW R28,2
; 0000 00C2 lcd_gotoxy(0, 0); lcd_string("System Ready");
	RCALL SUBOPT_0x5
	__POINTW2MN _0x22,0
	RCALL _lcd_string
; 0000 00C3 delay_ms(1000);
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	RCALL _delay_ms
; 0000 00C4 lcd_command(0x01);
	LDI  R26,LOW(1)
	RCALL _lcd_command
; 0000 00C5 
; 0000 00C6 #asm("sei")
	SEI
; 0000 00C7 
; 0000 00C8 while (1) {
_0x23:
; 0000 00C9 // --- 1. PC 데이터 처리 및 부저 제어 ---
; 0000 00CA if (msg_ready) {
	LDS  R30,_msg_ready
	CPI  R30,0
	BREQ _0x26
; 0000 00CB if (sscanf(rx_buffer, "%d,%c", &pc_bpm, &pc_status) == 2) {
	LDI  R30,LOW(_rx_buffer)
	LDI  R31,HIGH(_rx_buffer)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,28
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,20
	CLR  R22
	CLR  R23
	RCALL __PUTPARD1
	IN   R30,SPL
	IN   R31,SPH
	RCALL __PUTPARD1L
	PUSH R18
	LDI  R24,8
	RCALL _sscanf
	ADIW R28,12
	POP  R18
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x27
; 0000 00CC // LCD 갱신
; 0000 00CD sprintf(lcd_line, "HR: %d BPM    ", pc_bpm);
	MOVW R30,R28
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1FN _0x0,34
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	RCALL SUBOPT_0x6
	RCALL __PUTPARD1
	LDI  R24,4
	RCALL _sprintf
	ADIW R28,8
; 0000 00CE lcd_gotoxy(0, 0); lcd_string(lcd_line);
	RCALL SUBOPT_0x5
	MOVW R26,R28
	RCALL _lcd_string
; 0000 00CF 
; 0000 00D0 lcd_gotoxy(0, 1);
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(1)
	RCALL _lcd_gotoxy
; 0000 00D1 if (pc_status == 'N') lcd_string("Status: Normal  ");
	CPI  R18,78
	BRNE _0x28
	__POINTW2MN _0x22,13
	RJMP _0x4F
; 0000 00D2 else if (pc_status == 'W') lcd_string("Status: WARNING!");
_0x28:
	CPI  R18,87
	BRNE _0x2A
	__POINTW2MN _0x22,30
_0x4F:
	RCALL _lcd_string
; 0000 00D3 }
_0x2A:
; 0000 00D4 msg_ready = 0;
_0x27:
	LDI  R30,LOW(0)
	STS  _msg_ready,R30
; 0000 00D5 }
; 0000 00D6 
; 0000 00D7 // [수정됨] 부저 비동기 제어 로직
; 0000 00D8 if (pc_status == 'W') {
_0x26:
	CPI  R18,87
	BRNE _0x2B
; 0000 00D9 // timer_tick은 ISR에서 0~60까지 계속 돕니다 (약 1초 주기)
; 0000 00DA // 0 ~ 30 (약 0.5초): 켜짐
; 0000 00DB // 30 ~ 60 (약 0.5초): 꺼짐
; 0000 00DC if (timer_tick < 30) {
	LDS  R26,_timer_tick
	CPI  R26,LOW(0x1E)
	BRSH _0x2C
; 0000 00DD buzzer_on_2khz();
	RCALL _buzzer_on_2khz
; 0000 00DE } else {
	RJMP _0x2D
_0x2C:
; 0000 00DF buzzer_off();
	RCALL _buzzer_off
; 0000 00E0 }
_0x2D:
; 0000 00E1 } else {
	RJMP _0x2E
_0x2B:
; 0000 00E2 // 정상이면 항상 끔
; 0000 00E3 buzzer_off();
	RCALL _buzzer_off
; 0000 00E4 }
_0x2E:
; 0000 00E5 
; 0000 00E6 // --- 2. 센서 데이터 읽기 (기존과 동일) ---
; 0000 00E7 success = 1;
	LDI  R19,LOW(1)
; 0000 00E8 if (!MAX30102_readReg(REG_FIFO_WR_PTR, &ptr_w)) success = 0;
	LDI  R30,LOW(4)
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	PUSH R17
	RCALL _MAX30102_readReg
	POP  R17
	CPI  R30,0
	BRNE _0x2F
	LDI  R19,LOW(0)
; 0000 00E9 if (success && !MAX30102_readReg(REG_FIFO_RD_PTR, &ptr_r)) success = 0;
_0x2F:
	CPI  R19,0
	BREQ _0x31
	LDI  R30,LOW(6)
	ST   -Y,R30
	IN   R26,SPL
	IN   R27,SPH
	PUSH R16
	RCALL _MAX30102_readReg
	POP  R16
	CPI  R30,0
	BREQ _0x32
_0x31:
	RJMP _0x30
_0x32:
	LDI  R19,LOW(0)
; 0000 00EA 
; 0000 00EB if (success && (ptr_w != ptr_r)) {
_0x30:
	CPI  R19,0
	BREQ _0x34
	CP   R16,R17
	BRNE _0x35
_0x34:
	RJMP _0x33
_0x35:
; 0000 00EC if (!TWI_start()) success = 0;
	RCALL _TWI_start
	CPI  R30,0
	BRNE _0x36
	LDI  R19,LOW(0)
; 0000 00ED if (success && !TWI_write(MAX30102_ADDR_W)) success = 0;
_0x36:
	CPI  R19,0
	BREQ _0x38
	LDI  R26,LOW(174)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x39
_0x38:
	RJMP _0x37
_0x39:
	LDI  R19,LOW(0)
; 0000 00EE if (success && !TWI_write(REG_FIFO_DATA)) success = 0;
_0x37:
	CPI  R19,0
	BREQ _0x3B
	LDI  R26,LOW(7)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x3C
_0x3B:
	RJMP _0x3A
_0x3C:
	LDI  R19,LOW(0)
; 0000 00EF if (success && !TWI_start()) success = 0;
_0x3A:
	CPI  R19,0
	BREQ _0x3E
	RCALL _TWI_start
	CPI  R30,0
	BREQ _0x3F
_0x3E:
	RJMP _0x3D
_0x3F:
	LDI  R19,LOW(0)
; 0000 00F0 if (success && !TWI_write(MAX30102_ADDR_R)) success = 0;
_0x3D:
	CPI  R19,0
	BREQ _0x41
	LDI  R26,LOW(175)
	RCALL _TWI_write
	CPI  R30,0
	BREQ _0x42
_0x41:
	RJMP _0x40
_0x42:
	LDI  R19,LOW(0)
; 0000 00F1 
; 0000 00F2 if (success) {
_0x40:
	CPI  R19,0
	BREQ _0x43
; 0000 00F3 for(i=0; i<5; i++) { if (!TWI_read_ack(&d[i])) { success = 0; break; } }
	__GETWRN 20,21,0
_0x45:
	__CPWRN 20,21,5
	BRGE _0x46
	MOVW R26,R28
	ADIW R26,18
	ADD  R26,R20
	ADC  R27,R21
	RCALL _TWI_read_ack
	CPI  R30,0
	BRNE _0x47
	LDI  R19,LOW(0)
	RJMP _0x46
_0x47:
	__ADDWRN 20,21,1
	RJMP _0x45
_0x46:
; 0000 00F4 if (success && !TWI_read_nack(&d[5])) success = 0;
	CPI  R19,0
	BREQ _0x49
	MOVW R26,R28
	ADIW R26,23
	RCALL _TWI_read_nack
	CPI  R30,0
	BREQ _0x4A
_0x49:
	RJMP _0x48
_0x4A:
	LDI  R19,LOW(0)
; 0000 00F5 }
_0x48:
; 0000 00F6 if (success) TWI_stop();
_0x43:
	CPI  R19,0
	BREQ _0x4B
	RCALL _TWI_stop
; 0000 00F7 
; 0000 00F8 if (success) {
_0x4B:
	CPI  R19,0
	BREQ _0x4C
; 0000 00F9 red_val = ((uint32_t)d[0] << 16 | (uint32_t)d[1] << 8 | d[2]) & 0x03FFFF;
	LDD  R30,Y+18
	LDI  R31,0
	RCALL SUBOPT_0x6
	__LSLD16
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+19
	LDI  R31,0
	RCALL SUBOPT_0x6
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(8)
	RCALL __LSLD12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL SUBOPT_0x7
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+20
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL SUBOPT_0x7
	__ANDD1N 0x3FFFF
	__PUTD1S 24
; 0000 00FA printf("%ld\r\n", red_val);
	__POINTW1FN _0x0,83
	ST   -Y,R31
	ST   -Y,R30
	__GETD1S 26
	RCALL __PUTPARD1
	LDI  R24,4
	RCALL _printf
	ADIW R28,6
; 0000 00FB }
; 0000 00FC }
_0x4C:
; 0000 00FD 
; 0000 00FE if (!success) {
_0x33:
	CPI  R19,0
	BRNE _0x4D
; 0000 00FF TWCR = 0; delay_ms(10); TWI_init();
	LDI  R30,LOW(0)
	STS  116,R30
	LDI  R26,LOW(10)
	LDI  R27,0
	RCALL _delay_ms
	RCALL _TWI_init
; 0000 0100 }
; 0000 0101 }
_0x4D:
	RJMP _0x23
; 0000 0102 }
_0x4E:
	RJMP _0x4E
; .FEND

	.DSEG
_0x22:
	.BYTE 0x2F
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
	RCALL SUBOPT_0x8
_0x20A0005:
	RCALL __LOADLOCR4
	ADIW R28,5
	RET
; .FEND
_put_buff_G100:
; .FSTART _put_buff_G100
	RCALL __SAVELOCR6
	MOVW R18,R26
	LDD  R21,Y+6
	ADIW R26,2
	RCALL SUBOPT_0x9
	BREQ _0x2000010
	MOVW R26,R18
	RCALL SUBOPT_0xA
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x2000012
	__CPWRN 16,17,2
	BRLO _0x2000013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1RNS 18,4
_0x2000012:
	MOVW R26,R18
	ADIW R26,2
	RCALL SUBOPT_0x8
	SBIW R30,1
	ST   Z,R21
_0x2000013:
	MOVW R26,R18
	__GETW1P
	TST  R31
	BRMI _0x2000014
	RCALL SUBOPT_0x8
_0x2000014:
	RJMP _0x2000015
_0x2000010:
	MOVW R26,R18
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x2000015:
	RCALL __LOADLOCR6
	ADIW R28,7
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
	RCALL SUBOPT_0xB
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	RCALL SUBOPT_0xB
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
	RCALL SUBOPT_0xC
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	LDD  R26,Z+4
	ST   -Y,R26
	RCALL SUBOPT_0xD
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x73)
	BRNE _0x2000035
	RCALL SUBOPT_0xC
	RCALL SUBOPT_0xE
	RCALL _strlen
	MOV  R17,R30
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x70)
	BRNE _0x2000038
	RCALL SUBOPT_0xC
	RCALL SUBOPT_0xE
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
	RCALL SUBOPT_0xF
	LDI  R17,LOW(10)
	RJMP _0x2000041
_0x2000040:
	__GETD1N 0x2710
	RCALL SUBOPT_0xF
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
	RCALL SUBOPT_0xF
	LDI  R17,LOW(8)
	RJMP _0x2000041
_0x2000046:
	__GETD1N 0x1000
	RCALL SUBOPT_0xF
	LDI  R17,LOW(4)
_0x2000041:
	SBRS R16,1
	RJMP _0x2000047
	RCALL SUBOPT_0xC
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	ADIW R26,4
	RCALL __GETD1P
	RJMP _0x20000D3
_0x2000047:
	SBRS R16,2
	RJMP _0x2000049
	RCALL SUBOPT_0xC
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	RCALL SUBOPT_0xA
	RCALL SUBOPT_0x6
	RJMP _0x20000D3
_0x2000049:
	RCALL SUBOPT_0xC
	LDD  R26,Y+21
	LDD  R27,Y+21+1
	RCALL SUBOPT_0xA
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
	RCALL SUBOPT_0x10
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
	RCALL SUBOPT_0xB
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
	RCALL SUBOPT_0xB
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
	RCALL SUBOPT_0x11
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
	RCALL SUBOPT_0x12
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
	RCALL SUBOPT_0xD
	CPI  R21,0
	BREQ _0x2000071
	SUBI R21,LOW(1)
_0x2000071:
_0x2000070:
_0x200006F:
_0x2000067:
	RCALL SUBOPT_0xB
	CPI  R21,0
	BREQ _0x2000072
	SUBI R21,LOW(1)
_0x2000072:
_0x200006C:
	SUBI R19,LOW(1)
	RCALL SUBOPT_0x11
	RCALL __MODD21U
	RCALL SUBOPT_0x10
	LDD  R30,Y+16
	RCALL SUBOPT_0x12
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL __DIVD21U
	RCALL SUBOPT_0xF
	__GETD1S 8
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
	RCALL SUBOPT_0xD
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
_sprintf:
; .FSTART _sprintf
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	RCALL __SAVELOCR6
	RCALL SUBOPT_0x13
	__GETWRZ 20,21,14
	MOV  R0,R20
	OR   R0,R21
	BRNE _0x2000078
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0004
_0x2000078:
	MOVW R26,R28
	ADIW R26,8
	RCALL SUBOPT_0x14
	__PUTWSR 20,21,8
	LDI  R30,LOW(0)
	STD  Y+10,R30
	STD  Y+10+1,R30
	MOVW R26,R28
	ADIW R26,12
	RCALL SUBOPT_0x15
	LDI  R30,LOW(_put_buff_G100)
	LDI  R31,HIGH(_put_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,12
	RCALL __print_G100
	MOVW R18,R30
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x20A0004:
	RCALL __LOADLOCR6
	ADIW R28,12
	POP  R15
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
	RCALL SUBOPT_0x14
	LDI  R30,LOW(0)
	STD  Y+4,R30
	STD  Y+4+1,R30
	STD  Y+6,R30
	STD  Y+6+1,R30
	MOVW R26,R28
	ADIW R26,8
	RCALL SUBOPT_0x15
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
_get_buff_G100:
; .FSTART _get_buff_G100
	RCALL __SAVELOCR6
	MOVW R18,R26
	__GETWRS 20,21,6
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R26,R20
	LD   R30,X
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2000080
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x2000081
_0x2000080:
	MOVW R26,R18
	ADIW R26,1
	RCALL SUBOPT_0x9
	BREQ _0x2000082
	MOVW R30,R18
	LDD  R26,Z+1
	LDD  R27,Z+2
	LD   R30,X
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2000083
	MOVW R26,R18
	ADIW R26,1
	RCALL SUBOPT_0x8
_0x2000083:
	RJMP _0x2000084
_0x2000082:
	LDI  R17,LOW(0)
_0x2000084:
_0x2000081:
	MOV  R30,R17
	RCALL __LOADLOCR6
	ADIW R28,8
	RET
; .FEND
__scanf_G100:
; .FSTART __scanf_G100
	PUSH R15
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,4
	RCALL __SAVELOCR6
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	STD  Y+8,R30
	STD  Y+8+1,R31
	MOV  R20,R30
_0x2000085:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	ADIW R30,1
	STD  Y+16,R30
	STD  Y+16+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R19,R30
	CPI  R30,0
	BRNE PC+2
	RJMP _0x2000087
	MOV  R26,R19
	RCALL _isspace
	CPI  R30,0
	BREQ _0x2000088
_0x2000089:
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x200008C
	MOV  R26,R19
	RCALL _isspace
	CPI  R30,0
	BRNE _0x200008D
_0x200008C:
	RJMP _0x200008B
_0x200008D:
	RCALL SUBOPT_0x17
	BRGE _0x200008E
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x200008E:
	RJMP _0x2000089
_0x200008B:
	MOV  R20,R19
	RJMP _0x200008F
_0x2000088:
	CPI  R19,37
	BREQ PC+2
	RJMP _0x2000090
	LDI  R21,LOW(0)
_0x2000091:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LPM  R19,Z+
	STD  Y+16,R30
	STD  Y+16+1,R31
	CPI  R19,48
	BRLO _0x2000095
	CPI  R19,58
	BRLO _0x2000094
_0x2000095:
	RJMP _0x2000093
_0x2000094:
	LDI  R26,LOW(10)
	MUL  R21,R26
	MOV  R21,R0
	MOV  R30,R19
	SUBI R30,LOW(48)
	ADD  R21,R30
	RJMP _0x2000091
_0x2000093:
	CPI  R19,0
	BRNE _0x2000097
	RJMP _0x2000087
_0x2000097:
_0x2000098:
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	MOV  R18,R30
	MOV  R26,R30
	RCALL _isspace
	CPI  R30,0
	BREQ _0x200009A
	RCALL SUBOPT_0x17
	BRGE _0x200009B
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x200009B:
	RJMP _0x2000098
_0x200009A:
	CPI  R18,0
	BRNE _0x200009C
	RJMP _0x200009D
_0x200009C:
	MOV  R20,R18
	CPI  R21,0
	BRNE _0x200009E
	LDI  R21,LOW(255)
_0x200009E:
	MOV  R30,R19
	CPI  R30,LOW(0x63)
	BRNE _0x20000A2
	RCALL SUBOPT_0x18
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	MOVW R26,R16
	ST   X,R30
	RCALL SUBOPT_0x17
	BRGE _0x20000A3
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20000A3:
	RJMP _0x20000A1
_0x20000A2:
	CPI  R30,LOW(0x73)
	BRNE _0x20000AC
	RCALL SUBOPT_0x18
_0x20000A5:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BREQ _0x20000A7
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	MOV  R19,R30
	CPI  R30,0
	BREQ _0x20000A9
	MOV  R26,R19
	RCALL _isspace
	CPI  R30,0
	BREQ _0x20000A8
_0x20000A9:
	RCALL SUBOPT_0x17
	BRGE _0x20000AB
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20000AB:
	RJMP _0x20000A7
_0x20000A8:
	PUSH R17
	PUSH R16
	__ADDWRN 16,17,1
	MOV  R30,R19
	POP  R26
	POP  R27
	ST   X,R30
	RJMP _0x20000A5
_0x20000A7:
	MOVW R26,R16
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x20000A1
_0x20000AC:
	SET
	BLD  R15,1
	CLT
	BLD  R15,2
	MOV  R30,R19
	CPI  R30,LOW(0x64)
	BREQ _0x20000B1
	CPI  R30,LOW(0x69)
	BRNE _0x20000B2
_0x20000B1:
	CLT
	BLD  R15,1
	RJMP _0x20000B3
_0x20000B2:
	CPI  R30,LOW(0x75)
	BRNE _0x20000B4
_0x20000B3:
	LDI  R18,LOW(10)
	RJMP _0x20000AF
_0x20000B4:
	CPI  R30,LOW(0x78)
	BRNE _0x20000B5
	LDI  R18,LOW(16)
	RJMP _0x20000AF
_0x20000B5:
	CPI  R30,LOW(0x25)
	BRNE _0x20000B8
	RJMP _0x20000B7
_0x20000B8:
	RJMP _0x20A0003
_0x20000AF:
	LDI  R30,LOW(0)
	STD  Y+6,R30
	STD  Y+6+1,R30
	SET
	BLD  R15,0
_0x20000B9:
	MOV  R30,R21
	SUBI R21,1
	CPI  R30,0
	BRNE PC+2
	RJMP _0x20000BB
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	MOV  R19,R30
	CPI  R30,LOW(0x21)
	BRSH _0x20000BC
	RCALL SUBOPT_0x17
	BRGE _0x20000BD
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20000BD:
	RJMP _0x20000BE
_0x20000BC:
	SBRC R15,1
	RJMP _0x20000BF
	SET
	BLD  R15,1
	CPI  R19,45
	BRNE _0x20000C0
	BLD  R15,2
	RJMP _0x20000B9
_0x20000C0:
	CPI  R19,43
	BREQ _0x20000B9
_0x20000BF:
	CPI  R18,16
	BRNE _0x20000C2
	MOV  R26,R19
	RCALL _isxdigit
	CPI  R30,0
	BREQ _0x20000BE
	RJMP _0x20000C4
_0x20000C2:
	MOV  R26,R19
	RCALL _isdigit
	CPI  R30,0
	BRNE _0x20000C5
_0x20000BE:
	SBRC R15,0
	RJMP _0x20000C7
	MOV  R20,R19
	RJMP _0x20000BB
_0x20000C5:
_0x20000C4:
	CPI  R19,97
	BRLO _0x20000C8
	SUBI R19,LOW(87)
	RJMP _0x20000C9
_0x20000C8:
	CPI  R19,65
	BRLO _0x20000CA
	SUBI R19,LOW(55)
	RJMP _0x20000CB
_0x20000CA:
	SUBI R19,LOW(48)
_0x20000CB:
_0x20000C9:
	MOV  R30,R18
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R31,0
	RCALL __MULW12U
	MOVW R26,R30
	MOV  R30,R19
	LDI  R31,0
	ADD  R30,R26
	ADC  R31,R27
	STD  Y+6,R30
	STD  Y+6+1,R31
	CLT
	BLD  R15,0
	RJMP _0x20000B9
_0x20000BB:
	RCALL SUBOPT_0x18
	SBRS R15,2
	RJMP _0x20000CC
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	RCALL __ANEGW1
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x20000CC:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	MOVW R26,R16
	ST   X+,R30
	ST   X,R31
_0x20000A1:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	ADIW R30,1
	STD  Y+8,R30
	STD  Y+8+1,R31
	RJMP _0x20000CD
_0x2000090:
_0x20000B7:
	IN   R30,SPL
	IN   R31,SPH
	ST   -Y,R31
	ST   -Y,R30
	PUSH R20
	RCALL SUBOPT_0x16
	POP  R20
	CP   R30,R19
	BREQ _0x20000CE
	RCALL SUBOPT_0x17
	BRGE _0x20000CF
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20000CF:
_0x200009D:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	SBIW R30,0
	BRNE _0x20000D0
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0002
_0x20000D0:
	RJMP _0x2000087
_0x20000CE:
_0x20000CD:
_0x200008F:
	RJMP _0x2000085
_0x2000087:
_0x20000C7:
_0x20A0003:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
_0x20A0002:
	RCALL __LOADLOCR6
	ADIW R28,18
	POP  R15
	RET
; .FEND
_sscanf:
; .FSTART _sscanf
	PUSH R15
	MOV  R15,R24
	SBIW R28,3
	RCALL __SAVELOCR4
	RCALL SUBOPT_0x13
	__GETWRZ 18,19,9
	MOV  R0,R18
	OR   R0,R19
	BRNE _0x20000D1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x20A0001
_0x20000D1:
	MOVW R26,R28
	ADIW R26,3
	RCALL SUBOPT_0x14
	__PUTWSR 18,19,5
	MOVW R26,R28
	ADIW R26,7
	RCALL SUBOPT_0x15
	LDI  R30,LOW(_get_buff_G100)
	LDI  R31,HIGH(_get_buff_G100)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,10
	RCALL __scanf_G100
_0x20A0001:
	RCALL __LOADLOCR4
	ADIW R28,7
	POP  R15
	RET
; .FEND

	.CSEG

	.DSEG

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

	.CSEG
_isdigit:
; .FSTART _isdigit
	ST   -Y,R26
    ldi  r30,1
    ld   r31,y+
    cpi  r31,'0'
    brlo isdigit0
    cpi  r31,'9'+1
    brlo isdigit1
isdigit0:
    clr  r30
isdigit1:
    ret
; .FEND
_isspace:
; .FSTART _isspace
	ST   -Y,R26
    ldi  r30,1
    ld   r31,y+
    cpi  r31,' '
    breq isspace1
    cpi  r31,9
    brlo isspace0
    cpi  r31,13+1
    brlo isspace1
isspace0:
    clr  r30
isspace1:
    ret
; .FEND
_isxdigit:
; .FSTART _isxdigit
	ST   -Y,R26
    ldi  r30,1
    ld   r31,y+
    subi r31,0x30
    brcs isxdigit0
    cpi  r31,10
    brcs isxdigit1
    andi r31,0x5f
    subi r31,7
    cpi  r31,10
    brcs isxdigit0
    cpi  r31,16
    brcs isxdigit1
isxdigit0:
    clr  r30
isxdigit1:
    ret
; .FEND

	.CSEG

	.DSEG
_rx_buffer:
	.BYTE 0x14
_rx_index:
	.BYTE 0x1
_msg_ready:
	.BYTE 0x1
_timer_tick:
	.BYTE 0x1
__seed_G101:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	__DELAY_USW 400
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	LDI  R30,LOW(132)
	STS  116,R30
	RJMP _TWI_wait

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x2:
	LDS  R30,115
	MOVW R26,R16
	ST   X,R30
	LDI  R30,LOW(1)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x3:
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
	LDD  R16,Y+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4:
	LDI  R27,0
	RCALL _delay_ms
	LDI  R30,LOW(48)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RJMP _lcd_send_nibble

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RJMP _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x6:
	__CWD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7:
	__ORD12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x8:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x9:
	__GETW1P
	SBIW R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0xA:
	ADIW R26,4
	__GETW1P
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0xB:
	ST   -Y,R18
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0xC:
	LDD  R30,Y+21
	LDD  R31,Y+21+1
	SBIW R30,4
	STD  Y+21,R30
	STD  Y+21+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xD:
	LDD  R26,Y+18
	LDD  R27,Y+18+1
	LDD  R30,Y+20
	LDD  R31,Y+20+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xE:
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
SUBOPT_0xF:
	__PUTD1S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x10:
	__PUTD1S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x11:
	__GETD1S 8
	__GETD2S 12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x12:
	__GETD2S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x13:
	MOVW R30,R28
	__ADDW1R15
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x14:
	__ADDW2R15
	MOVW R16,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x15:
	__ADDW2R15
	LD   R30,X+
	LD   R31,X+
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x16:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x17:
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	LD   R26,X
	CPI  R26,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0x18:
	LDD  R30,Y+14
	LDD  R31,Y+14+1
	SBIW R30,4
	STD  Y+14,R30
	STD  Y+14+1,R31
	LDD  R26,Y+14
	LDD  R27,Y+14+1
	ADIW R26,4
	LD   R16,X+
	LD   R17,X
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

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
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

__MULW12:
__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
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

__PUTPARD1L:
	LDI  R22,0
	LDI  R23,0
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
