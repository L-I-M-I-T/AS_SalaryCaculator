;1853971 王天，K1853971.asm
DATA 	SEGMENT
N   	EQU     6	;统计的天数
STA	EQU	100	;每日基准件数
BAS	EQU	2200	;每日基本工资
MORE	EQU	15	;超出部分每件奖励工资
LESS	EQU	12	;不足部分每件扣除工资
MIN	EQU	0	;件数下限
MAX	EQU	999	;件数上限
C10	DW	10
NUM  	DW      N DUP(0)
ANS	DD	0
FLAG	DB	0	;标志变量，记录是否读到过回车外的字符
PLEASE1	DB   	"Please input the NUM of day ",'$'
PLEASE2	DB   	" (range from ",'$'
PLEASE3	DB   	" to ",'$'
PLEASE4	DB   	") : ",'$'
RESULT	DB	"The total wage is : ",'$'
ERRMSG1	DB   	0AH,0DH,"Non-number characters contained, please retry.",0AH,0DH,'$'
ERRMSG2	DB   	"Numbers exceeded out of range, please retry.",0AH,0DH,'$'
DATA 	ENDS
CODE    SEGMENT
        ASSUME  CS:CODE,DS:DATA
;-----------------------------------------------
;子程序名：DISP
;功能：将寄存器AX中的数据以十进制显示出来
;入口参数：AX
;出口参数：无
;-----------------------------------------------
DISP	PROC	FAR
	PUSH	DX
	PUSH	CX
	PUSH	BX
	MOV	CX,0	;计数器
	MOV	BX,10
REP1:	MOV	DX,0
	DIV	BX	;除以10取余
	ADD	DX,30H  ;DX加30H
	PUSH	DX	;先低后高入栈
	INC	CX	;计余数个数
	OR	AX,AX
	JNZ	REP1	;商0结束循环
REP2:	POP	DX	;先高后低弹出
	MOV	AH,2	;显示
	INT	21H
	LOOP	REP2
	POP	BX
	POP	CX
	POP	DX
	RET
DISP	ENDP
;-----------------------------------------------
;子程序名：INPUT
;功能：从键盘输入一周中每天的快递量并进行错误处理
;入口参数：无
;出口参数：NUM
;-----------------------------------------------
INPUT	PROC	FAR
	LEA	BX,NUM
	MOV	CX,1
L1:	LEA	DX,PLEASE1
	MOV	AH,9
	INT	21H
	MOV	AX,CX
	CALL	DISP
	LEA	DX,PLEASE2
	MOV	AH,9
	INT	21H
	MOV	AX,MIN
	CALL	DISP
	LEA	DX,PLEASE3
	MOV	AH,9
	INT	21H
	MOV	AX,MAX
	CALL	DISP
	LEA	DX,PLEASE4
	MOV	AH,9
	INT	21H
L2:	MOV	AH,1
	INT	21H
	CMP	AL,0DH
	JE	DONE
	CMP	AL,39H
	JA	ERROR1
	CMP	AL,30H
	JB	ERROR1
	MOV	FLAG,1
	MOV	DX,AX	;输入字符转移到CX寄存器
	AND	DX,000FH;转换成二进制数	
	MOV	AX,[BX]
	PUSH	DX
	MUL	C10
	POP	DX
	ADD	AX,DX	;新输入数字拼接到已输入数字中
	MOV	[BX],AX
	JMP	L2
DONE:	CMP	FLAG,0
	JE	L2
	CMP	WORD PTR [BX],MAX
	JA	ERROR2
	CMP	WORD PTR [BX],MIN
	JB	ERROR2
	INC	BX
	INC	BX
	INC	CX
	CMP	CX,N
	JA	EXIT
	MOV	FLAG,0
	JMP	L1
ERROR1:	LEA	DX,ERRMSG1
	MOV	AH,9
	INT	21H
	MOV	WORD PTR [BX],0
	MOV	FLAG,0
	JMP	L1
ERROR2:	LEA	DX,ERRMSG2
	MOV	AH,9
	INT	21H
	MOV	WORD PTR [BX],0
	MOV	FLAG,0
	JMP	L1
EXIT:	RET
INPUT	ENDP
;-----------------------------------------------
;子程序名：SOLVE
;功能：根据各日件数计算总工资
;入口参数：BX
;出口参数：ANS
;-----------------------------------------------
SOLVE	PROC
	LEA	BX,NUM
	MOV	CX,N
L3:	MOV	AX,[BX]
	CMP	AX,STA
	JA	EL
	MOV	AX,STA
	SUB	AX,[BX]
	MOV	DX,LESS
	MUL	DX
	NEG	AX
	JMP	AC
EL:	SUB	AX,STA
	MOV	DX,MORE
	MUL	DX
AC:	ADD	AX,BAS
	ADD	WORD PTR [ANS],AX
	ADC	WORD PTR [ANS+2],0
	INC	BX
	INC	BX
	LOOP	L3
	RET
SOLVE	ENDP
;-----------------------------------------------
;子程序名：OUTPUT
;功能：输出总工资，保留一位小数
;入口参数：ANS
;出口参数：无
;-----------------------------------------------
OUTPUT	PROC
	LEA	DX,RESULT
	MOV	AH,9
	INT	21H
	MOV	AX,WORD PTR [ANS]
	MOV	DX,WORD PTR [ANS+2]
	DIV	C10
	PUSH	DX
	CALL	DISP
	MOV	AH,2
	MOV	DL,'.'
	INT	21H
	POP	AX
	CALL	DISP
	RET
OUTPUT	ENDP
;-----------------------------------------------
;子程序名：MAIN
;功能：主程序
;入口参数：无
;出口参数：无
;-----------------------------------------------
MAIN	PROC	FAR
	PUSH	DS
	MOV	AX,0
	PUSH	AX
	MOV	AX,DATA
	MOV	DS,AX
	CALL	INPUT
	CALL	SOLVE
	CALL	OUTPUT
	RET
MAIN	ENDP
CODE    ENDS
       	END	MAIN