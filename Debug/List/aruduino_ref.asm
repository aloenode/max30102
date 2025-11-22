
;CodeVisionAVR C Compiler V4.05 Evaluation
;(C) Copyright 1998-2025 Pavel Haiduc, HP InfoTech S.R.L.
;http://www.hpinfotech.ro

;Build configuration    : Debug
;Chip type              : ATmega128A
;Program type           : Application
;Clock frequency        : 16.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
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

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _finger_detected=R5
	.DEF _crossed=R4

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
	JMP  _timer0_comp_isr
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
	JMP  0x00
	JMP  0x00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0

_0x0:
	.DB  0x53,0x79,0x73,0x74,0x65,0x6D,0x20,0x52
	.DB  0x65,0x61,0x64,0x79,0x20,0x28,0x4C,0x69
	.DB  0x74,0x65,0x29,0xD,0xA,0x0,0x46,0x69
	.DB  0x6E,0x67,0x65,0x72,0x20,0x52,0x65,0x6D
	.DB  0x6F,0x76,0x65,0x64,0xD,0xA,0x0,0x42
	.DB  0x50,0x4D,0x3A,0x25,0x64,0x2C,0x20,0x53
	.DB  0x70,0x4F,0x32,0x3A,0x25,0x64,0x2C,0x20
	.DB  0x52,0x3A,0x25,0x64,0x2E,0x25,0x30,0x32
	.DB  0x64,0xD,0xA,0x0

__GLOBAL_INI_TBL:
	.DW  0x02
	.DW  0x04
	.DW  __REG_VARS*2

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
;interrupt [16] void timer0_comp_isr(void) {
; 0000 0012 interrupt [16] void timer0_comp_isr(void) {

	.CSEG
_timer0_comp_isr:
; .FSTART _timer0_comp_isr
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0013 millis_counter++;
	LDI  R26,LOW(_millis_counter)
	LDI  R27,HIGH(_millis_counter)
	RCALL SUBOPT_0x0
	__SUBD1N -1
	__PUTDP1_DEC
; 0000 0014 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R23,Y+
	LD   R22,Y+
	RETI
; .FEND
;unsigned long millis(void) {
; 0000 0016 unsigned long millis(void) {
_millis:
; .FSTART _millis
; 0000 0017 unsigned long m;
; 0000 0018 #asm("cli")
	SBIW R28,4
;	m -> Y+0
	CLI
; 0000 0019 m = millis_counter;
	LDS  R30,_millis_counter
	LDS  R31,_millis_counter+1
	LDS  R22,_millis_counter+2
	LDS  R23,_millis_counter+3
	RCALL SUBOPT_0x1
; 0000 001A #asm("sei")
	SEI
; 0000 001B return m;
	__GETD1S 0
	ADIW R28,4
	RET
; 0000 001C }
; .FEND
;void Timer0_Init(void) {
; 0000 001E void Timer0_Init(void) {
_Timer0_Init:
; .FSTART _Timer0_Init
; 0000 001F // CTC Mode, Prescaler 64
; 0000 0020 TCCR0 = (1<<WGM01) | (1<<CS01) | (1<<CS00);
	LDI  R30,LOW(11)
	OUT  0x33,R30
; 0000 0021 TCNT0 = 0x00;
	LDI  R30,LOW(0)
	OUT  0x32,R30
; 0000 0022 OCR0  = 249;
	LDI  R30,LOW(249)
	OUT  0x31,R30
; 0000 0023 TIMSK |= (1<<OCIE0);
	IN   R30,0x37
	ORI  R30,2
	OUT  0x37,R30
; 0000 0024 }
	RET
; .FEND
;void LPF_Reset(LPF_t *filter) { filter->init_flag = 0; }
; 0000 0035 void LPF_Reset(LPF_t *filter) { filter->init_flag = 0; }
_LPF_Reset:
; .FSTART _LPF_Reset
	RCALL SUBOPT_0x2
;	*filter -> R16,R17
	ADIW R26,4
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x2060002
; .FEND
;float LPF_Process(LPF_t *filter, float val) {
; 0000 0037 float LPF_Process(LPF_t *filter, float val) {
_LPF_Process:
; .FSTART _LPF_Process
; 0000 0038 if (filter->init_flag == 0) {
	RCALL SUBOPT_0x3
;	*filter -> R16,R17
;	val -> Y+2
	LDD  R30,Z+4
	CPI  R30,0
	BRNE _0x3
; 0000 0039 filter->last_val = val;
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x5
; 0000 003A filter->init_flag = 1;
	RCALL SUBOPT_0x6
; 0000 003B } else {
	RJMP _0x4
_0x3:
; 0000 003C // 상수 0.2696, 0.7304 직접 사용
; 0000 003D filter->last_val = 0.2696 * val + 0.7304 * filter->last_val;
	RCALL SUBOPT_0x4
	__GETD2N 0x3E8A0903
	RCALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	RCALL SUBOPT_0x0
	__GETD2N 0x3F3AFB7F
	RCALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __ADDF12
	RCALL SUBOPT_0x5
; 0000 003E }
_0x4:
; 0000 003F return filter->last_val;
	MOVW R26,R16
	RCALL SUBOPT_0x0
	RJMP _0x2060003
; 0000 0040 }
; .FEND
;void HPF_Reset(HPF_t *filter) { filter->init_flag = 0; }
; 0000 004D void HPF_Reset(HPF_t *filter) { filter->init_flag = 0; }
_HPF_Reset:
; .FSTART _HPF_Reset
	RCALL SUBOPT_0x2
;	*filter -> R16,R17
	ADIW R26,8
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x2060002
; .FEND
;float HPF_Process(HPF_t *filter, float val) {
; 0000 004F float HPF_Process(HPF_t *filter, float val) {
_HPF_Process:
; .FSTART _HPF_Process
; 0000 0050 if (filter->init_flag == 0) {
	RCALL SUBOPT_0x3
;	*filter -> R16,R17
;	val -> Y+2
	LDD  R30,Z+8
	CPI  R30,0
	BRNE _0x5
; 0000 0051 filter->last_filter_val = 0;
	MOVW R26,R16
	RCALL SUBOPT_0x7
; 0000 0052 filter->init_flag = 1;
	ADIW R26,8
	LDI  R30,LOW(1)
	ST   X,R30
; 0000 0053 } else {
	RJMP _0x6
_0x5:
; 0000 0054 // 상수 직접 사용
; 0000 0055 filter->last_filter_val = 0.9845 * val
; 0000 0056 - 0.9845 * filter->last_raw_val
; 0000 0057 + 0.9690 * filter->last_filter_val;
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x8
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	ADIW R26,4
	RCALL SUBOPT_0x0
	RCALL SUBOPT_0x8
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __SWAPD12
	RCALL __SUBF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	MOVW R26,R16
	RCALL SUBOPT_0x0
	__GETD2N 0x3F781062
	RCALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __ADDF12
	RCALL SUBOPT_0x5
; 0000 0058 }
_0x6:
; 0000 0059 filter->last_raw_val = val;
	RCALL SUBOPT_0x9
; 0000 005A return filter->last_filter_val;
	MOVW R26,R16
	RCALL SUBOPT_0x0
	RJMP _0x2060003
; 0000 005B }
; .FEND
;void Diff_Reset(Diff_t *diff) { diff->init_flag = 0; }
; 0000 0063 void Diff_Reset(Diff_t *diff) { diff->init_flag = 0; }
_Diff_Reset:
; .FSTART _Diff_Reset
	RCALL SUBOPT_0x2
;	*diff -> R16,R17
	ADIW R26,4
	LDI  R30,LOW(0)
	ST   X,R30
	RJMP _0x2060002
; .FEND
;float Diff_Process(Diff_t *diff, float val) {
; 0000 0065 float Diff_Process(Diff_t *diff, float val) {
_Diff_Process:
; .FSTART _Diff_Process
; 0000 0066 float output = 0;
; 0000 0067 if (diff->init_flag == 1) {
	RCALL __PUTPARD2
	SBIW R28,4
	LDI  R30,LOW(0)
	ST   Y,R30
	STD  Y+1,R30
	STD  Y+2,R30
	STD  Y+3,R30
	ST   -Y,R17
	ST   -Y,R16
	__GETWRS 16,17,10
;	*diff -> R16,R17
;	val -> Y+6
;	output -> Y+2
	MOVW R30,R16
	LDD  R26,Z+4
	CPI  R26,LOW(0x1)
	BRNE _0x7
; 0000 0068 // Sampling Rate 100.0 곱하기
; 0000 0069 output = (val - diff->last_val) * 100.0;
	MOVW R26,R16
	RCALL SUBOPT_0x0
	__GETD2S 6
	RCALL SUBOPT_0xA
	__PUTD1S 2
; 0000 006A } else {
	RJMP _0x8
_0x7:
; 0000 006B diff->init_flag = 1;
	RCALL SUBOPT_0x6
; 0000 006C }
_0x8:
; 0000 006D diff->last_val = val;
	RCALL SUBOPT_0xB
	RCALL SUBOPT_0x5
; 0000 006E return output;
	RCALL SUBOPT_0x4
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,12
	RET
; 0000 006F }
; .FEND
;void Stat_Reset(Stat_t *stat) {
; 0000 0079 void Stat_Reset(Stat_t *stat) {
_Stat_Reset:
; .FSTART _Stat_Reset
; 0000 007A stat->min_val = 1000000.0;
	RCALL SUBOPT_0x2
;	*stat -> R16,R17
	__GETD1N 0x49742400
	RCALL SUBOPT_0xC
; 0000 007B stat->max_val = -1000000.0;
	ADIW R26,4
	__GETD1N 0xC9742400
	RCALL SUBOPT_0xC
; 0000 007C stat->sum_val = 0;
	ADIW R26,8
	RCALL SUBOPT_0x7
; 0000 007D stat->count = 0;
	ADIW R26,12
	RCALL SUBOPT_0xD
; 0000 007E }
	RJMP _0x2060002
; .FEND
;void Stat_Process(Stat_t *stat, float val) {
; 0000 0080 void Stat_Process(Stat_t *stat, float val) {
_Stat_Process:
; .FSTART _Stat_Process
; 0000 0081 if (val < stat->min_val) stat->min_val = val;
	RCALL __PUTPARD2
	ST   -Y,R17
	ST   -Y,R16
	__GETWRS 16,17,6
;	*stat -> R16,R17
;	val -> Y+2
	MOVW R26,R16
	RCALL SUBOPT_0xE
	BRSH _0x9
	RCALL SUBOPT_0x4
	RCALL SUBOPT_0x5
; 0000 0082 if (val > stat->max_val) stat->max_val = val;
_0x9:
	MOVW R26,R16
	ADIW R26,4
	RCALL SUBOPT_0xE
	BREQ PC+2
	BRCC PC+2
	RJMP _0xA
	RCALL SUBOPT_0x9
; 0000 0083 stat->sum_val += val;
_0xA:
	MOVW R30,R16
	ADIW R30,8
	PUSH R31
	PUSH R30
	MOVW R26,R30
	RCALL SUBOPT_0x0
	__GETD2S 2
	RCALL __ADDF12
	POP  R26
	POP  R27
	RCALL SUBOPT_0xC
; 0000 0084 stat->count++;
	ADIW R26,12
	RCALL SUBOPT_0xF
; 0000 0085 }
_0x2060003:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,8
	RET
; .FEND
;float Stat_GetAvg(Stat_t *stat) {
; 0000 0087 float Stat_GetAvg(Stat_t *stat) {
_Stat_GetAvg:
; .FSTART _Stat_GetAvg
; 0000 0088 if (stat->count == 0) return 0;
	RCALL SUBOPT_0x2
;	*stat -> R16,R17
	ADIW R26,12
	__GETW1P
	SBIW R30,0
	BRNE _0xB
	__GETD1N 0x0
	RJMP _0x2060002
; 0000 0089 return stat->sum_val / stat->count;
_0xB:
	MOVW R30,R16
	__GETD2Z 8
	MOVW R0,R26
	MOVW R26,R16
	ADIW R26,12
	LD   R30,X+
	LD   R31,X+
	MOVW R26,R0
	RCALL SUBOPT_0x10
	RCALL __DIVF21
_0x2060002:
	LD   R16,Y+
	LD   R17,Y+
	RET
; 0000 008A }
; .FEND
;void UART0_init(void) {
; 0000 0092 void UART0_init(void) {
_UART0_init:
; .FSTART _UART0_init
; 0000 0093 UBRR0H = 0; UBRR0L = 103; // 9600bps
	LDI  R30,LOW(0)
	STS  144,R30
	LDI  R30,LOW(103)
	OUT  0x9,R30
; 0000 0094 UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	LDI  R30,LOW(24)
	OUT  0xA,R30
; 0000 0095 UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 0096 }
	RET
; .FEND
;void TWI_init(void) { (*(unsigned char *) 0x71)=0x00; (*(unsigned char *) 0x70)=12; }
; 0000 0098 void TWI_init(void) { (*(unsigned char *) 0x71)=0x00; (*(unsigned char *) 0x70)=12; }
_TWI_init:
; .FSTART _TWI_init
	LDI  R30,LOW(0)
	STS  113,R30
	LDI  R30,LOW(12)
	STS  112,R30
	RET
; .FEND
;void TWI_start(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<5       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); }
; 0000 0099 void TWI_start(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<5       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); }
_TWI_start:
; .FSTART _TWI_start
	LDI  R30,LOW(164)
	STS  116,R30
_0xC:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0xC
	RET
; .FEND
;void TWI_stop(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<4       )|(1<<2       ); }
; 0000 009A void TWI_stop(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<4       )|(1<<2       ); }
_TWI_stop:
; .FSTART _TWI_stop
	LDI  R30,LOW(148)
	STS  116,R30
	RET
; .FEND
;void TWI_write(uint8_t d) { (*(unsigned char *) 0x73)=d; (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); }
; 0000 009B void TWI_write(uint8_t d) { (*(unsigned char *) 0x73)=d; (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); }
_TWI_write:
; .FSTART _TWI_write
	ST   -Y,R17
	MOV  R17,R26
;	d -> R17
	STS  115,R17
	LDI  R30,LOW(132)
	STS  116,R30
_0xF:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0xF
	LD   R17,Y+
	RET
; .FEND
;uint8_t TWI_read_ack(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       )|(1<<6       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); return (*(unsigned char *) 0x73); }
; 0000 009C uint8_t TWI_read_ack(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       )|(1<<6       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); return (*(unsigned char *) 0x73); }
_TWI_read_ack:
; .FSTART _TWI_read_ack
	LDI  R30,LOW(196)
	STS  116,R30
_0x12:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x12
	RJMP _0x2060001
; .FEND
;uint8_t TWI_read_nack(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); return (*(unsigned char *) 0x73); }
; 0000 009D uint8_t TWI_read_nack(void) { (*(unsigned char *) 0x74)=(1<<7       )|(1<<2       ); while(!((*(unsigned char *) 0x74)&(1<<7       ))); return (*(unsigned char *) 0x73); }
_TWI_read_nack:
; .FSTART _TWI_read_nack
	LDI  R30,LOW(132)
	STS  116,R30
_0x15:
	LDS  R30,116
	ANDI R30,LOW(0x80)
	BREQ _0x15
_0x2060001:
	LDS  R30,115
	RET
; .FEND
;void WriteReg(uint8_t r, uint8_t v) {
; 0000 009F void WriteReg(uint8_t r, uint8_t v) {
_WriteReg:
; .FSTART _WriteReg
; 0000 00A0 TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(r); TWI_write(v); TWI_stop();
	ST   -Y,R17
	ST   -Y,R16
	MOV  R17,R26
	LDD  R16,Y+2
;	r -> R16
;	v -> R17
	RCALL _TWI_start
	LDI  R26,LOW(174)
	RCALL _TWI_write
	MOV  R26,R16
	RCALL _TWI_write
	MOV  R26,R17
	RCALL _TWI_write
	RCALL _TWI_stop
; 0000 00A1 }
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,3
	RET
; .FEND
;void MAX30102_Init_400Hz() {
; 0000 00A3 void MAX30102_Init_400Hz() {
_MAX30102_Init_400Hz:
; .FSTART _MAX30102_Init_400Hz
; 0000 00A4 WriteReg(0x09, 0x40); delay_ms(100);
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(64)
	RCALL _WriteReg
	LDI  R26,LOW(100)
	LDI  R27,0
	RCALL _delay_ms
; 0000 00A5 WriteReg(0x02, 0xC0);
	LDI  R30,LOW(2)
	ST   -Y,R30
	LDI  R26,LOW(192)
	RCALL _WriteReg
; 0000 00A6 WriteReg(0x08, 0x50);
	LDI  R30,LOW(8)
	ST   -Y,R30
	LDI  R26,LOW(80)
	RCALL _WriteReg
; 0000 00A7 WriteReg(0x0A, 0x2F);
	LDI  R30,LOW(10)
	ST   -Y,R30
	LDI  R26,LOW(47)
	RCALL _WriteReg
; 0000 00A8 WriteReg(0x0C, 0x24);
	LDI  R30,LOW(12)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _WriteReg
; 0000 00A9 WriteReg(0x0D, 0x24);
	LDI  R30,LOW(13)
	ST   -Y,R30
	LDI  R26,LOW(36)
	RCALL _WriteReg
; 0000 00AA WriteReg(0x09, 0x03);
	LDI  R30,LOW(9)
	ST   -Y,R30
	LDI  R26,LOW(3)
	RCALL _WriteReg
; 0000 00AB }
	RET
; .FEND
;void ReadFIFO(uint32_t *r, uint32_t *ir) {
; 0000 00AD void ReadFIFO(uint32_t *r, uint32_t *ir) {
_ReadFIFO:
; .FSTART _ReadFIFO
; 0000 00AE uint8_t t[6];
; 0000 00AF unsigned char i;
; 0000 00B0 TWI_start(); TWI_write(MAX30102_ADDR_W); TWI_write(0x07);
	SBIW R28,6
	RCALL __SAVELOCR6
	MOVW R18,R26
	__GETWRS 20,21,12
;	*r -> R20,R21
;	*ir -> R18,R19
;	t -> Y+6
;	i -> R17
	RCALL _TWI_start
	LDI  R26,LOW(174)
	RCALL _TWI_write
	LDI  R26,LOW(7)
	RCALL _TWI_write
; 0000 00B1 TWI_start(); TWI_write(MAX30102_ADDR_R);
	RCALL _TWI_start
	LDI  R26,LOW(175)
	RCALL _TWI_write
; 0000 00B2 for(i=0; i<5; i++) t[i]=TWI_read_ack();
	LDI  R17,LOW(0)
_0x19:
	CPI  R17,5
	BRSH _0x1A
	MOV  R30,R17
	LDI  R31,0
	MOVW R26,R28
	ADIW R26,6
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	RCALL _TWI_read_ack
	POP  R26
	POP  R27
	ST   X,R30
	SUBI R17,-1
	RJMP _0x19
_0x1A:
; 0000 00B3 t[5]=TWI_read_nack();
	RCALL _TWI_read_nack
	STD  Y+11,R30
; 0000 00B4 TWI_stop();
	RCALL _TWI_stop
; 0000 00B5 *r = ((uint32_t)t[0]<<16 | (uint32_t)t[1]<<8 | t[2]) & 0x3FFFF;
	LDD  R30,Y+6
	RCALL SUBOPT_0x11
	RCALL SUBOPT_0x12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+7
	RCALL SUBOPT_0x11
	RCALL SUBOPT_0x13
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL SUBOPT_0x14
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+8
	RCALL SUBOPT_0x15
	MOVW R26,R20
	RCALL SUBOPT_0x16
; 0000 00B6 *ir= ((uint32_t)t[3]<<16 | (uint32_t)t[4]<<8 | t[5]) & 0x3FFFF;
	LDD  R30,Y+9
	RCALL SUBOPT_0x11
	RCALL SUBOPT_0x12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDD  R30,Y+10
	RCALL SUBOPT_0x11
	RCALL SUBOPT_0x13
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL SUBOPT_0x14
	MOVW R26,R30
	MOVW R24,R22
	LDD  R30,Y+11
	RCALL SUBOPT_0x15
	MOVW R26,R18
	RCALL SUBOPT_0x16
; 0000 00B7 }
	RCALL __LOADLOCR6
	ADIW R28,14
	RET
; .FEND
;void Reset_All_Filters() {
; 0000 00C9 void Reset_All_Filters() {
_Reset_All_Filters:
; .FSTART _Reset_All_Filters
; 0000 00CA LPF_Reset(&lpf_red);
	LDI  R26,LOW(_lpf_red)
	LDI  R27,HIGH(_lpf_red)
	RCALL _LPF_Reset
; 0000 00CB LPF_Reset(&lpf_ir);
	LDI  R26,LOW(_lpf_ir)
	LDI  R27,HIGH(_lpf_ir)
	RCALL _LPF_Reset
; 0000 00CC HPF_Reset(&hpf_red);
	LDI  R26,LOW(_hpf_red)
	LDI  R27,HIGH(_hpf_red)
	RCALL _HPF_Reset
; 0000 00CD Diff_Reset(&diff_red);
	LDI  R26,LOW(_diff_red)
	LDI  R27,HIGH(_diff_red)
	RCALL _Diff_Reset
; 0000 00CE Stat_Reset(&stat_red);
	RCALL SUBOPT_0x17
; 0000 00CF Stat_Reset(&stat_ir);
; 0000 00D0 finger_detected = 0;
	CLR  R5
; 0000 00D1 finger_timestamp = millis();
	RCALL _millis
	STS  _finger_timestamp,R30
	STS  _finger_timestamp+1,R31
	STS  _finger_timestamp+2,R22
	STS  _finger_timestamp+3,R23
; 0000 00D2 }
	RET
; .FEND
;void main(void) {
; 0000 00D4 void main(void) {
_main:
; .FSTART _main
; 0000 00D5 uint32_t raw_red, raw_ir;
; 0000 00D6 float f_red, f_ir, f_val, f_diff;
; 0000 00D7 long interval;
; 0000 00D8 int bpm;
; 0000 00D9 float r_red, r_ir, r, spo2;
; 0000 00DA int r_int, r_dec;
; 0000 00DB 
; 0000 00DC UART0_init();
	SBIW R28,44
;	raw_red -> Y+40
;	raw_ir -> Y+36
;	f_red -> Y+32
;	f_ir -> Y+28
;	f_val -> Y+24
;	f_diff -> Y+20
;	interval -> Y+16
;	bpm -> R16,R17
;	r_red -> Y+12
;	r_ir -> Y+8
;	r -> Y+4
;	spo2 -> Y+0
;	r_int -> R18,R19
;	r_dec -> R20,R21
	RCALL _UART0_init
; 0000 00DD TWI_init();
	RCALL _TWI_init
; 0000 00DE Timer0_Init();
	RCALL _Timer0_Init
; 0000 00DF 
; 0000 00E0 #asm("sei")
	SEI
; 0000 00E1 
; 0000 00E2 delay_ms(1000);
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	RCALL _delay_ms
; 0000 00E3 printf("System Ready (Lite)\r\n");
	__POINTW1FN _0x0,0
	RCALL SUBOPT_0x18
; 0000 00E4 
; 0000 00E5 MAX30102_Init_400Hz();
	RCALL _MAX30102_Init_400Hz
; 0000 00E6 Reset_All_Filters();
	RCALL _Reset_All_Filters
; 0000 00E7 
; 0000 00E8 while (1) {
_0x1B:
; 0000 00E9 ReadFIFO(&raw_red, &raw_ir);
	MOVW R30,R28
	ADIW R30,40
	ST   -Y,R31
	ST   -Y,R30
	MOVW R26,R28
	ADIW R26,38
	RCALL _ReadFIFO
; 0000 00EA 
; 0000 00EB f_red = (float)raw_red;
	__GETD1S 40
	RCALL __CDF1U
	RCALL SUBOPT_0x19
; 0000 00EC f_ir = (float)raw_ir;
	__GETD1S 36
	RCALL __CDF1U
	RCALL SUBOPT_0x1A
; 0000 00ED 
; 0000 00EE // 손가락 감지 (Threshold 10000)
; 0000 00EF if (raw_red > 10000) {
	__GETD2S 40
	__CPD2N 0x2711
	BRLO _0x1E
; 0000 00F0 if ((millis() - finger_timestamp) > 500) {
	RCALL _millis
	MOVW R26,R30
	MOVW R24,R22
	LDS  R30,_finger_timestamp
	LDS  R31,_finger_timestamp+1
	LDS  R22,_finger_timestamp+2
	LDS  R23,_finger_timestamp+3
	__SUBD21
	__CPD2N 0x1F5
	BRLO _0x1F
; 0000 00F1 finger_detected = 1;
	LDI  R30,LOW(1)
	MOV  R5,R30
; 0000 00F2 }
; 0000 00F3 } else {
_0x1F:
	RJMP _0x20
_0x1E:
; 0000 00F4 if (finger_detected) {
	TST  R5
	BREQ _0x21
; 0000 00F5 Reset_All_Filters();
	RCALL _Reset_All_Filters
; 0000 00F6 printf("Finger Removed\r\n");
	__POINTW1FN _0x0,22
	RCALL SUBOPT_0x18
; 0000 00F7 }
; 0000 00F8 }
_0x21:
_0x20:
; 0000 00F9 
; 0000 00FA if (finger_detected) {
	TST  R5
	BRNE PC+2
	RJMP _0x22
; 0000 00FB // 필터 처리
; 0000 00FC f_red = LPF_Process(&lpf_red, f_red);
	LDI  R30,LOW(_lpf_red)
	LDI  R31,HIGH(_lpf_red)
	RCALL SUBOPT_0x1B
	RCALL _LPF_Process
	RCALL SUBOPT_0x19
; 0000 00FD f_ir  = LPF_Process(&lpf_ir, f_ir);
	LDI  R30,LOW(_lpf_ir)
	LDI  R31,HIGH(_lpf_ir)
	RCALL SUBOPT_0x1C
	RCALL _LPF_Process
	RCALL SUBOPT_0x1A
; 0000 00FE 
; 0000 00FF Stat_Process(&stat_red, f_red);
	LDI  R30,LOW(_stat_red)
	LDI  R31,HIGH(_stat_red)
	RCALL SUBOPT_0x1B
	RCALL _Stat_Process
; 0000 0100 Stat_Process(&stat_ir, f_ir);
	LDI  R30,LOW(_stat_ir)
	LDI  R31,HIGH(_stat_ir)
	RCALL SUBOPT_0x1C
	RCALL _Stat_Process
; 0000 0101 
; 0000 0102 f_val = HPF_Process(&hpf_red, f_red);
	LDI  R30,LOW(_hpf_red)
	LDI  R31,HIGH(_hpf_red)
	RCALL SUBOPT_0x1B
	RCALL _HPF_Process
	__PUTD1S 24
; 0000 0103 f_diff = Diff_Process(&diff_red, f_val);
	LDI  R30,LOW(_diff_red)
	LDI  R31,HIGH(_diff_red)
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 26
	RCALL _Diff_Process
	__PUTD1S 20
; 0000 0104 
; 0000 0105 // Beat Detection
; 0000 0106 if (last_diff > 0 && f_diff < 0) {
	LDS  R26,_last_diff
	LDS  R27,_last_diff+1
	LDS  R24,_last_diff+2
	LDS  R25,_last_diff+3
	RCALL __CPD02
	BRGE _0x24
	LDD  R26,Y+23
	TST  R26
	BRMI _0x25
_0x24:
	RJMP _0x23
_0x25:
; 0000 0107 crossed = 1;
	LDI  R30,LOW(1)
	MOV  R4,R30
; 0000 0108 crossed_time = millis();
	RCALL _millis
	STS  _crossed_time,R30
	STS  _crossed_time+1,R31
	STS  _crossed_time+2,R22
	STS  _crossed_time+3,R23
; 0000 0109 }
; 0000 010A if (f_diff > 0) crossed = 0;
_0x23:
	RCALL SUBOPT_0x1D
	RCALL __CPD02
	BRGE _0x26
	CLR  R4
; 0000 010B 
; 0000 010C // Edge Check (-2000.0)
; 0000 010D if (crossed && f_diff < -2000.0) {
_0x26:
	TST  R4
	BREQ _0x28
	RCALL SUBOPT_0x1D
	__GETD1N 0xC4FA0000
	RCALL __CMPF12
	BRLO _0x29
_0x28:
	RJMP _0x27
_0x29:
; 0000 010E if (last_heartbeat != 0 && (crossed_time - last_heartbeat) > 300) {
	RCALL SUBOPT_0x1E
	RCALL __CPD02
	BREQ _0x2B
	RCALL SUBOPT_0x1F
	__CPD1N 0x12D
	BRGE _0x2C
_0x2B:
	RJMP _0x2A
_0x2C:
; 0000 010F 
; 0000 0110 interval = crossed_time - last_heartbeat;
	RCALL SUBOPT_0x1F
	__PUTD1S 16
; 0000 0111 bpm = 60000 / interval;
	__GETD2N 0xEA60
	RCALL __DIVD21
	MOVW R16,R30
; 0000 0112 
; 0000 0113 r_red = (stat_red.max_val - stat_red.min_val) / Stat_GetAvg(&stat_red);
	__GETD1MN _stat_red,4
	LDS  R26,_stat_red
	LDS  R27,_stat_red+1
	LDS  R24,_stat_red+2
	LDS  R25,_stat_red+3
	RCALL __SUBF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDI  R26,LOW(_stat_red)
	LDI  R27,HIGH(_stat_red)
	RCALL _Stat_GetAvg
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __DIVF21
	__PUTD1S 12
; 0000 0114 r_ir  = (stat_ir.max_val - stat_ir.min_val) / Stat_GetAvg(&stat_ir);
	__GETD1MN _stat_ir,4
	LDS  R26,_stat_ir
	LDS  R27,_stat_ir+1
	LDS  R24,_stat_ir+2
	LDS  R25,_stat_ir+3
	RCALL __SUBF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	LDI  R26,LOW(_stat_ir)
	LDI  R27,HIGH(_stat_ir)
	RCALL _Stat_GetAvg
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __DIVF21
	__PUTD1S 8
; 0000 0115 
; 0000 0116 r = 0;
	LDI  R30,LOW(0)
	__CLRD1S 4
; 0000 0117 if (r_ir != 0) r = r_red / r_ir;
	RCALL SUBOPT_0x20
	__CPD10
	BREQ _0x2D
	RCALL SUBOPT_0x20
	__GETD2S 12
	RCALL __DIVF21
	__PUTD1S 4
; 0000 0118 
; 0000 0119 // SpO2 = A*r^2 + B*r + C
; 0000 011A spo2 = 1.5958 * r * r - 34.659 * r + 112.689;
_0x2D:
	RCALL SUBOPT_0x21
	__GETD2N 0x3FCC432D
	RCALL __MULF12
	RCALL SUBOPT_0x22
	RCALL __MULF12
	PUSH R23
	PUSH R22
	PUSH R31
	PUSH R30
	RCALL SUBOPT_0x21
	__GETD2N 0x420AA2D1
	RCALL __MULF12
	POP  R26
	POP  R27
	POP  R24
	POP  R25
	RCALL __SWAPD12
	RCALL __SUBF12
	__GETD2N 0x42E160C5
	RCALL __ADDF12
	RCALL SUBOPT_0x1
; 0000 011B 
; 0000 011C if (bpm > 40 && bpm < 220) {
	__CPWRN 16,17,41
	BRLT _0x2F
	__CPWRN 16,17,220
	BRLT _0x30
_0x2F:
	RJMP _0x2E
_0x30:
; 0000 011D r_int = (int)r;
	RCALL SUBOPT_0x21
	RCALL __CFD1
	MOVW R18,R30
; 0000 011E r_dec = (int)((r - r_int) * 100);
	RCALL SUBOPT_0x22
	RCALL SUBOPT_0x10
	RCALL SUBOPT_0xA
	RCALL __CFD1
	MOVW R20,R30
; 0000 011F if(r_dec < 0) r_dec = -r_dec;
	TST  R21
	BRPL _0x31
	RCALL __ANEGW1
	MOVW R20,R30
; 0000 0120 
; 0000 0121 printf("BPM:%d, SpO2:%d, R:%d.%02d\r\n", bpm, (int)spo2, r_int, r_dec);
_0x31:
	__POINTW1FN _0x0,39
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R16
	RCALL SUBOPT_0x23
	RCALL SUBOPT_0xB
	RCALL __CFD1
	RCALL SUBOPT_0x23
	MOVW R30,R18
	RCALL SUBOPT_0x23
	MOVW R30,R20
	RCALL SUBOPT_0x23
	LDI  R24,16
	RCALL _printf
	ADIW R28,18
; 0000 0122 }
; 0000 0123 
; 0000 0124 Stat_Reset(&stat_red);
_0x2E:
	RCALL SUBOPT_0x17
; 0000 0125 Stat_Reset(&stat_ir);
; 0000 0126 
; 0000 0127 last_heartbeat = crossed_time;
	LDS  R30,_crossed_time
	LDS  R31,_crossed_time+1
	LDS  R22,_crossed_time+2
	LDS  R23,_crossed_time+3
	STS  _last_heartbeat,R30
	STS  _last_heartbeat+1,R31
	STS  _last_heartbeat+2,R22
	STS  _last_heartbeat+3,R23
; 0000 0128 crossed = 0;
	CLR  R4
; 0000 0129 }
; 0000 012A }
_0x2A:
; 0000 012B last_diff = f_diff;
_0x27:
	__GETD1S 20
	STS  _last_diff,R30
	STS  _last_diff+1,R31
	STS  _last_diff+2,R22
	STS  _last_diff+3,R23
; 0000 012C }
; 0000 012D 
; 0000 012E delay_ms(10);
_0x22:
	LDI  R26,LOW(10)
	LDI  R27,0
	RCALL _delay_ms
; 0000 012F }
	RJMP _0x1B
; 0000 0130 }
_0x32:
	RJMP _0x32
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
	RCALL SUBOPT_0xF
	RCALL __LOADLOCR4
	ADIW R28,5
	RET
; .FEND
__print_G100:
; .FSTART __print_G100
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,6
	RCALL __SAVELOCR6
	LDI  R17,0
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	RCALL SUBOPT_0xD
_0x2000016:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,1
	STD  Y+18,R30
	STD  Y+18+1,R31
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
	RCALL SUBOPT_0x24
_0x200001E:
	RJMP _0x200001B
_0x200001C:
	CPI  R30,LOW(0x1)
	BRNE _0x200001F
	CPI  R18,37
	BRNE _0x2000020
	RCALL SUBOPT_0x24
	RJMP _0x20000CC
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
	BREQ PC+2
	RJMP _0x200001B
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
	MOV  R30,R18
	CPI  R30,LOW(0x63)
	BRNE _0x200002F
	RCALL SUBOPT_0x25
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LDD  R26,Z+4
	ST   -Y,R26
	RCALL SUBOPT_0x26
	RJMP _0x2000030
_0x200002F:
	CPI  R30,LOW(0x73)
	BRNE _0x2000032
	RCALL SUBOPT_0x25
	RCALL SUBOPT_0x27
	RCALL _strlen
	MOV  R17,R30
	RJMP _0x2000033
_0x2000032:
	CPI  R30,LOW(0x70)
	BRNE _0x2000035
	RCALL SUBOPT_0x25
	RCALL SUBOPT_0x27
	RCALL _strlenf
	MOV  R17,R30
	ORI  R16,LOW(8)
_0x2000033:
	ORI  R16,LOW(2)
	ANDI R16,LOW(127)
	LDI  R19,LOW(0)
	RJMP _0x2000036
_0x2000035:
	CPI  R30,LOW(0x64)
	BREQ _0x2000039
	CPI  R30,LOW(0x69)
	BRNE _0x200003A
_0x2000039:
	ORI  R16,LOW(4)
	RJMP _0x200003B
_0x200003A:
	CPI  R30,LOW(0x75)
	BRNE _0x200003C
_0x200003B:
	LDI  R30,LOW(_tbl10_G100*2)
	LDI  R31,HIGH(_tbl10_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(5)
	RJMP _0x200003D
_0x200003C:
	CPI  R30,LOW(0x58)
	BRNE _0x200003F
	ORI  R16,LOW(8)
	RJMP _0x2000040
_0x200003F:
	CPI  R30,LOW(0x78)
	BREQ PC+2
	RJMP _0x2000071
_0x2000040:
	LDI  R30,LOW(_tbl16_G100*2)
	LDI  R31,HIGH(_tbl16_G100*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R17,LOW(4)
_0x200003D:
	SBRS R16,2
	RJMP _0x2000042
	RCALL SUBOPT_0x25
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	LD   R30,X+
	LD   R31,X+
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDD  R26,Y+11
	TST  R26
	BRPL _0x2000043
	RCALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R20,LOW(45)
_0x2000043:
	CPI  R20,0
	BREQ _0x2000044
	SUBI R17,-LOW(1)
	RJMP _0x2000045
_0x2000044:
	ANDI R16,LOW(251)
_0x2000045:
	RJMP _0x2000046
_0x2000042:
	RCALL SUBOPT_0x25
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	__GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
_0x2000046:
_0x2000036:
	SBRC R16,0
	RJMP _0x2000047
_0x2000048:
	CP   R17,R21
	BRSH _0x200004A
	SBRS R16,7
	RJMP _0x200004B
	SBRS R16,2
	RJMP _0x200004C
	ANDI R16,LOW(251)
	MOV  R18,R20
	SUBI R17,LOW(1)
	RJMP _0x200004D
_0x200004C:
	LDI  R18,LOW(48)
_0x200004D:
	RJMP _0x200004E
_0x200004B:
	LDI  R18,LOW(32)
_0x200004E:
	RCALL SUBOPT_0x24
	SUBI R21,LOW(1)
	RJMP _0x2000048
_0x200004A:
_0x2000047:
	MOV  R19,R17
	SBRS R16,1
	RJMP _0x200004F
_0x2000050:
	CPI  R19,0
	BREQ _0x2000052
	SBRS R16,3
	RJMP _0x2000053
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R18,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x2000054
_0x2000053:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R18,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x2000054:
	RCALL SUBOPT_0x24
	CPI  R21,0
	BREQ _0x2000055
	SUBI R21,LOW(1)
_0x2000055:
	SUBI R19,LOW(1)
	RJMP _0x2000050
_0x2000052:
	RJMP _0x2000056
_0x200004F:
_0x2000058:
	LDI  R18,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	RCALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x200005A:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x200005C
	SUBI R18,-LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SUB  R30,R26
	SBC  R31,R27
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x200005A
_0x200005C:
	CPI  R18,58
	BRLO _0x200005D
	SBRS R16,3
	RJMP _0x200005E
	SUBI R18,-LOW(7)
	RJMP _0x200005F
_0x200005E:
	SUBI R18,-LOW(39)
_0x200005F:
_0x200005D:
	SBRC R16,4
	RJMP _0x2000061
	CPI  R18,49
	BRSH _0x2000063
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,1
	BRNE _0x2000062
_0x2000063:
	RJMP _0x20000CD
_0x2000062:
	CP   R21,R19
	BRLO _0x2000067
	SBRS R16,0
	RJMP _0x2000068
_0x2000067:
	RJMP _0x2000066
_0x2000068:
	LDI  R18,LOW(32)
	SBRS R16,7
	RJMP _0x2000069
	LDI  R18,LOW(48)
_0x20000CD:
	ORI  R16,LOW(16)
	SBRS R16,2
	RJMP _0x200006A
	ANDI R16,LOW(251)
	ST   -Y,R20
	RCALL SUBOPT_0x26
	CPI  R21,0
	BREQ _0x200006B
	SUBI R21,LOW(1)
_0x200006B:
_0x200006A:
_0x2000069:
_0x2000061:
	RCALL SUBOPT_0x24
	CPI  R21,0
	BREQ _0x200006C
	SUBI R21,LOW(1)
_0x200006C:
_0x2000066:
	SUBI R19,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,2
	BRLO _0x2000059
	RJMP _0x2000058
_0x2000059:
_0x2000056:
	SBRS R16,0
	RJMP _0x200006D
_0x200006E:
	CPI  R21,0
	BREQ _0x2000070
	SUBI R21,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	RCALL SUBOPT_0x26
	RJMP _0x200006E
_0x2000070:
_0x200006D:
_0x2000071:
_0x2000030:
_0x20000CC:
	LDI  R17,LOW(0)
_0x200001B:
	RJMP _0x2000016
_0x2000018:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LD   R30,X+
	LD   R31,X+
	RCALL __LOADLOCR6
	ADIW R28,20
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
_millis_counter:
	.BYTE 0x4
_lpf_red:
	.BYTE 0x5
_lpf_ir:
	.BYTE 0x5
_hpf_red:
	.BYTE 0x9
_diff_red:
	.BYTE 0x5
_stat_red:
	.BYTE 0xE
_stat_ir:
	.BYTE 0xE
_last_heartbeat:
	.BYTE 0x4
_finger_timestamp:
	.BYTE 0x4
_last_diff:
	.BYTE 0x4
_crossed_time:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:25 WORDS
SUBOPT_0x0:
	__GETD1P_INC
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	__PUTD1S 0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x2:
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3:
	RCALL __PUTPARD2
	ST   -Y,R17
	ST   -Y,R16
	__GETWRS 16,17,6
	MOVW R30,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0x4:
	__GETD1S 2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x5:
	MOVW R26,R16
	__PUTDP1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x6:
	MOVW R26,R16
	ADIW R26,4
	LDI  R30,LOW(1)
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x7:
	__GETD1N 0x0
	__PUTDP1
	MOVW R26,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x8:
	__GETD2N 0x3F7C0831
	RCALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x9:
	RCALL SUBOPT_0x4
	__PUTD1RNS 16,4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0xA:
	RCALL __SWAPD12
	RCALL __SUBF12
	__GETD2N 0x42C80000
	RCALL __MULF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xB:
	__GETD1S 6
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0xC:
	__PUTDP1
	MOVW R26,R16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xD:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xE:
	RCALL SUBOPT_0x0
	__GETD2S 2
	RCALL __CMPF12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0xF:
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x10:
	__CWD1
	RCALL __CDF1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x11:
	LDI  R31,0
	__CWD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x12:
	__LSLD16
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x13:
	MOVW R26,R30
	MOVW R24,R22
	LDI  R30,LOW(8)
	RCALL __LSLD12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x14:
	__ORD12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x15:
	CLR  R31
	CLR  R22
	CLR  R23
	RCALL SUBOPT_0x14
	__ANDD1N 0x3FFFF
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x16:
	__PUTDP1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x17:
	LDI  R26,LOW(_stat_red)
	LDI  R27,HIGH(_stat_red)
	RCALL _Stat_Reset
	LDI  R26,LOW(_stat_ir)
	LDI  R27,HIGH(_stat_ir)
	RJMP _Stat_Reset

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x18:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R24,0
	RCALL _printf
	ADIW R28,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x19:
	__PUTD1S 32
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1A:
	__PUTD1S 28
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x1B:
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 34
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1C:
	ST   -Y,R31
	ST   -Y,R30
	__GETD2S 30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	__GETD2S 20
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x1E:
	LDS  R26,_last_heartbeat
	LDS  R27,_last_heartbeat+1
	LDS  R24,_last_heartbeat+2
	LDS  R25,_last_heartbeat+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x1F:
	RCALL SUBOPT_0x1E
	LDS  R30,_crossed_time
	LDS  R31,_crossed_time+1
	LDS  R22,_crossed_time+2
	LDS  R23,_crossed_time+3
	__SUBD12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	__GETD1S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x21:
	__GETD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x22:
	__GETD2S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x23:
	__CWD1
	RCALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x24:
	ST   -Y,R18
	LDD  R26,Y+13
	LDD  R27,Y+13+1
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x25:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x26:
	LDD  R26,Y+13
	LDD  R27,Y+13+1
	LDD  R30,Y+15
	LDD  R31,Y+15+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x27:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	LD   R30,X+
	LD   R31,X+
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
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

__ANEGD2:
	COM  R27
	COM  R24
	COM  R25
	NEG  R26
	SBCI R27,-1
	SBCI R24,-1
	SBCI R25,-1
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

__DIVD21:
	RCALL __CHKSIGND
	RCALL __DIVD21U
	BRTC __DIVD211
	RCALL __ANEGD1
__DIVD211:
	RET

__CHKSIGND:
	CLT
	SBRS R23,7
	RJMP __CHKSD1
	RCALL __ANEGD1
	SET
__CHKSD1:
	SBRS R25,7
	RJMP __CHKSD2
	RCALL __ANEGD2
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSD2:
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__PUTPARD2:
	ST   -Y,R25
	ST   -Y,R24
	ST   -Y,R27
	ST   -Y,R26
	RET

__SWAPD12:
	MOV  R1,R24
	MOV  R24,R22
	MOV  R22,R1
	MOV  R1,R25
	MOV  R25,R23
	MOV  R23,R1

__SWAPW12:
	MOV  R1,R27
	MOV  R27,R31
	MOV  R31,R1

__SWAPB12:
	MOV  R1,R26
	MOV  R26,R30
	MOV  R30,R1
	RET

__CPD02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	CPC  R0,R24
	CPC  R0,R25
	RET

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__SWAPACC:
	PUSH R20
	MOVW R20,R30
	MOVW R30,R26
	MOVW R26,R20
	MOVW R20,R22
	MOVW R22,R24
	MOVW R24,R20
	MOV  R20,R0
	MOV  R0,R1
	MOV  R1,R20
	POP  R20
	RET

__UADD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	RET

__NEGMAN1:
	COM  R30
	COM  R31
	COM  R22
	SUBI R30,-1
	SBCI R31,-1
	SBCI R22,-1
	RET

__SUBF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129
	LDI  R21,0x80
	EOR  R1,R21

	RJMP __ADDF120

__ADDF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R25,0x80
	BREQ __ADDF129

__ADDF120:
	CPI  R23,0x80
	BREQ __ADDF128
__ADDF121:
	MOV  R21,R23
	SUB  R21,R25
	BRVS __ADDF1211
	BRPL __ADDF122
	RCALL __SWAPACC
	RJMP __ADDF121
__ADDF122:
	CPI  R21,24
	BRLO __ADDF123
	CLR  R26
	CLR  R27
	CLR  R24
__ADDF123:
	CPI  R21,8
	BRLO __ADDF124
	MOV  R26,R27
	MOV  R27,R24
	CLR  R24
	SUBI R21,8
	RJMP __ADDF123
__ADDF124:
	TST  R21
	BREQ __ADDF126
__ADDF125:
	LSR  R24
	ROR  R27
	ROR  R26
	DEC  R21
	BRNE __ADDF125
__ADDF126:
	MOV  R21,R0
	EOR  R21,R1
	BRMI __ADDF127
	RCALL __UADD12
	BRCC __ADDF129
	ROR  R22
	ROR  R31
	ROR  R30
	INC  R23
	BRVC __ADDF129
	RJMP __MAXRES
__ADDF128:
	RCALL __SWAPACC
__ADDF129:
	RCALL __REPACK
	POP  R21
	RET
__ADDF1211:
	BRCC __ADDF128
	RJMP __ADDF129
__ADDF127:
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	BREQ __ZERORES
	BRCC __ADDF1210
	COM  R0
	RCALL __NEGMAN1
__ADDF1210:
	TST  R22
	BRMI __ADDF129
	LSL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVC __ADDF1210

__ZERORES:
	CLR  R30
	CLR  R31
	MOVW R22,R30
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	MOVW R20,R18
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__CMPF12:
	TST  R25
	BRMI __CMPF120
	TST  R23
	BRMI __CMPF121
	CP   R25,R23
	BRLO __CMPF122
	BRNE __CMPF121
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	BRLO __CMPF122
	BREQ __CMPF123
__CMPF121:
	CLZ
	CLC
	RET
__CMPF122:
	CLZ
	SEC
	RET
__CMPF123:
	SEZ
	CLC
	RET
__CMPF120:
	TST  R23
	BRPL __CMPF122
	CP   R25,R23
	BRLO __CMPF121
	BRNE __CMPF122
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	BRLO __CMPF122
	BREQ __CMPF123
	RJMP __CMPF121

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
