#include "textflag.h"
#define R10 g
#define ROUND()\
	ADD.S	R2,R0,R0;\
	ADC	R3,R1,R1;\
	EOR	R2<<13,R0,R8;\
	EOR	R3>>19,R8,R8;\
	EOR	R2>>19,R1,R11;\
	EOR	R3<<13,R11,R11;\
	ADD.S	R6,R4,R4;\
	ADC	R7,R5,R5;\
	EOR	R6<<16,R4,R2;\
	EOR	R7>>16,R2,R2;\
	EOR	R6>>16,R5,R3;\
	EOR	R7<<16,R3,R3;\
	ADD.S	R2,R1,R1;\
	ADC	R3,R0,R0;\
	EOR	R2<<21,R1,R6;\
	EOR	R3>>11,R6,R6;\
	EOR	R2>>11,R0,R7;\
	EOR	R3<<21,R7,R7;\
	ADD.S	R8,R4,R4;\
	ADC	R11,R5,R5;\
	EOR	R8<<17,R4,R2;\
	EOR	R11>>15,R2,R2;\
	EOR	R8>>15,R5,R3;\
	EOR	R11<<17,R3,R3;\
	ADD.S	R2,R1,R1;\
	ADC	R3,R0,R0;\
	EOR	R2<<13,R1,R8;\
	EOR	R3>>19,R8,R8;\
	EOR	R2>>19,R0,R11;\
	EOR	R3<<13,R11,R11;\
	ADD.S	R6,R5,R5;\
	ADC	R7,R4,R4;\
	EOR	R6<<16,R5,R2;\
	EOR	R7>>16,R2,R2;\
	EOR	R6>>16,R4,R3;\
	EOR	R7<<16,R3,R3;\
	ADD.S	R2,R0,R0;\
	ADC	R3,R1,R1;\
	EOR	R2<<21,R0,R6;\
	EOR	R3>>11,R6,R6;\
	EOR	R2>>11,R1,R7;\
	EOR	R3<<21,R7,R7;\
	ADD.S	R8,R5,R5;\
	ADC	R11,R4,R4;\
	EOR	R8<<17,R5,R2;\
	EOR	R11>>15,R2,R2;\
	EOR	R8>>15,R4,R3;\
	EOR	R11<<17,R3,R3;\

// once(d *digest)
TEXT ·once(SB),NOSPLIT,$4-4
	MOVW	d+0(FP),R8
	MOVM.IA	(R8),[R0,R1,R2,R3,R4,R5,R6,R7]
	MOVW	48(R8),R12
	MOVW	52(R8),R14
	EOR	R12,R6,R6
	EOR	R14,R7,R7
	ROUND()
	EOR	R12,R0,R0
	EOR	R14,R1,R1
	MOVW	d+0(FP),R8
	MOVM.IA [R0,R1,R2,R3,R4,R5,R6,R7],(R8)
	RET

// finalize(d *digest) uint64
TEXT ·finalize(SB),NOSPLIT,$4-12
	MOVW	d+0(FP),R8
	MOVM.IA	(R8),[R0,R1,R2,R3,R4,R5,R6,R7]
	MOVW	48(R8),R12
	MOVW	52(R8),R14
	EOR	R12,R6,R6
	EOR	R14,R7,R7
	ROUND()
	EOR	R12,R0,R0
	EOR	R14,R1,R1
	EOR	$255,R4
	ROUND()
	ROUND()
	EOR	R2,R0,R0
	EOR	R3,R1,R1
	EOR	R6,R4,R4
	EOR	R7,R5,R5
	EOR	R4,R0,R0
	EOR	R5,R1,R1
	MOVW	R0,ret_lo+4(FP)
	MOVW	R1,ret_hi+8(FP)
	RET

// blocks(d *digest, data []uint8)
TEXT ·blocks(SB),NOSPLIT,$8-16
	MOVW	R10,sav-8(SP)
	MOVW	d+0(FP),R8
	MOVM.IA	(R8),[R0,R1,R2,R3,R4,R5,R6,R7]
	MOVW	p+4(FP),R10
	MOVW	p_len+8(FP),R11
	ADD	R10,R11,R11
	MOVW	R11,endp-4(SP)
	AND.S	$3,R10,R8
	BNE	blocksunaligned
blocksloop:
	MOVM.IA.W (R10),[R12,R14]
	EOR	R12,R6,R6
	EOR	R14,R7,R7
	ROUND()
	EOR	R12,R0,R0
	EOR	R14,R1,R1
	MOVW	endp-4(SP),R11
	CMP	R11,R10
	BLO	blocksloop
	MOVW	d+0(FP),R8
	MOVM.IA [R0,R1,R2,R3,R4,R5,R6,R7],(R8)
	MOVW	sav-8(SP),R10
	RET
blocksunaligned:
	MOVB	(R10),R12
	MOVB	1(R10),R11
	ORR	R11<<8,R12,R12
	MOVB	2(R10),R11
	ORR	R11<<16,R12,R12
	MOVB	3(R10),R11
	ORR	R11<<24,R12,R12
	MOVB	4(R10),R14
	MOVB	5(R10),R11
	ORR	R11<<8,R14,R14
	MOVB	6(R10),R11
	ORR	R11<<16,R14,R14
	MOVB	7(R10),R11
	ORR	R11<<24,R14,R14
	ADD	$8,R10,R10
	EOR	R12,R6,R6
	EOR	R14,R7,R7
	ROUND()
	EOR	R12,R0,R0
	EOR	R14,R1,R1
	MOVW	endp-4(SP),R11
	CMP	R11,R10
	BLO	blocksunaligned
	MOVW	d+0(FP),R8
	MOVM.IA [R0,R1,R2,R3,R4,R5,R6,R7],(R8)
	MOVW	sav-8(SP),R10
	RET