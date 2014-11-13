/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>

###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn''t call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn''t push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.comm intr_ret_eip, 4
.comm intr_ebp_reg, 4
.comm intr_esp_reg, 4
.comm intr_cs, 4
.comm intr_eflags, 4

.globl in_intr
.comm in_intr, 1

.text
	TRAPHANDLER(h0, 0);
	TRAPHANDLER(h1, 1);
	TRAPHANDLER(h2, 2);
	TRAPHANDLER(h3, 3);
	TRAPHANDLER(h4, 4);
	TRAPHANDLER(h5, 5);
	TRAPHANDLER(h6, 6);
	TRAPHANDLER(h7, 7);
	TRAPHANDLER(h8, 8);
	TRAPHANDLER_NOEC(h9, 9);
	TRAPHANDLER(h10, 10);
	TRAPHANDLER(h11, 11);
	TRAPHANDLER(h12, 12);
	TRAPHANDLER(h13, 13);
	TRAPHANDLER(h14, 14);
	TRAPHANDLER_NOEC(h15, 15);
	TRAPHANDLER(h16, 16);
	TRAPHANDLER(h17, 17);
	TRAPHANDLER(h18, 18);
	TRAPHANDLER(h19, 19);
	TRAPHANDLER_NOEC(h20, 20);
	TRAPHANDLER_NOEC(h21, 21);
	TRAPHANDLER_NOEC(h22, 22);
	TRAPHANDLER_NOEC(h23, 23);
	TRAPHANDLER_NOEC(h24, 24);
	TRAPHANDLER_NOEC(h25, 25);
	TRAPHANDLER_NOEC(h26, 26);
	TRAPHANDLER_NOEC(h27, 27);
	TRAPHANDLER_NOEC(h28, 28);
	TRAPHANDLER_NOEC(h29, 29);
	TRAPHANDLER_NOEC(h30, 30);
	TRAPHANDLER_NOEC(h31, 31);
	TRAPHANDLER_NOEC(h32, 32);
	TRAPHANDLER_NOEC(h33, 33);
	TRAPHANDLER_NOEC(h34, 34);
	TRAPHANDLER_NOEC(h35, 35);
	TRAPHANDLER_NOEC(h36, 36);
	TRAPHANDLER_NOEC(h37, 37);
	TRAPHANDLER_NOEC(h38, 38);
	TRAPHANDLER_NOEC(h39, 39);
	TRAPHANDLER_NOEC(h40, 40);
	TRAPHANDLER_NOEC(h41, 41);
	TRAPHANDLER_NOEC(h42, 42);
	TRAPHANDLER_NOEC(h43, 43);
	TRAPHANDLER_NOEC(h44, 44);
	TRAPHANDLER_NOEC(h45, 45);
	TRAPHANDLER_NOEC(h46, 46);
	TRAPHANDLER_NOEC(h47, 47);
	TRAPHANDLER_NOEC(h48, 48);
	TRAPHANDLER_NOEC(h49, 49);
	TRAPHANDLER_NOEC(h50, 50);
	TRAPHANDLER_NOEC(h51, 51);
	TRAPHANDLER_NOEC(h52, 52);
	TRAPHANDLER_NOEC(h53, 53);
	TRAPHANDLER_NOEC(h54, 54);
	TRAPHANDLER_NOEC(h55, 55);
	TRAPHANDLER_NOEC(h56, 56);
	TRAPHANDLER_NOEC(h57, 57);
	TRAPHANDLER_NOEC(h58, 58);
	TRAPHANDLER_NOEC(h59, 59);
	TRAPHANDLER_NOEC(h60, 60);
	TRAPHANDLER_NOEC(h61, 61);
	TRAPHANDLER_NOEC(h62, 62);
	TRAPHANDLER_NOEC(h63, 63);
	TRAPHANDLER_NOEC(h64, 64);
	TRAPHANDLER_NOEC(h65, 65);
	TRAPHANDLER_NOEC(h66, 66);
	TRAPHANDLER_NOEC(h67, 67);
	TRAPHANDLER_NOEC(h68, 68);
	TRAPHANDLER_NOEC(h69, 69);
	TRAPHANDLER_NOEC(h70, 70);
	TRAPHANDLER_NOEC(h71, 71);
	TRAPHANDLER_NOEC(h72, 72);
	TRAPHANDLER_NOEC(h73, 73);
	TRAPHANDLER_NOEC(h74, 74);
	TRAPHANDLER_NOEC(h75, 75);
	TRAPHANDLER_NOEC(h76, 76);
	TRAPHANDLER_NOEC(h77, 77);
	TRAPHANDLER_NOEC(h78, 78);
	TRAPHANDLER_NOEC(h79, 79);
	TRAPHANDLER_NOEC(h80, 80);
	TRAPHANDLER_NOEC(h81, 81);
	TRAPHANDLER_NOEC(h82, 82);
	TRAPHANDLER_NOEC(h83, 83);
	TRAPHANDLER_NOEC(h84, 84);
	TRAPHANDLER_NOEC(h85, 85);
	TRAPHANDLER_NOEC(h86, 86);
	TRAPHANDLER_NOEC(h87, 87);
	TRAPHANDLER_NOEC(h88, 88);
	TRAPHANDLER_NOEC(h89, 89);
	TRAPHANDLER_NOEC(h90, 90);
	TRAPHANDLER_NOEC(h91, 91);
	TRAPHANDLER_NOEC(h92, 92);
	TRAPHANDLER_NOEC(h93, 93);
	TRAPHANDLER_NOEC(h94, 94);
	TRAPHANDLER_NOEC(h95, 95);
	TRAPHANDLER_NOEC(h96, 96);
	TRAPHANDLER_NOEC(h97, 97);
	TRAPHANDLER_NOEC(h98, 98);
	TRAPHANDLER_NOEC(h99, 99);
	TRAPHANDLER_NOEC(h100, 100);
	TRAPHANDLER_NOEC(h101, 101);
	TRAPHANDLER_NOEC(h102, 102);
	TRAPHANDLER_NOEC(h103, 103);
	TRAPHANDLER_NOEC(h104, 104);
	TRAPHANDLER_NOEC(h105, 105);
	TRAPHANDLER_NOEC(h106, 106);
	TRAPHANDLER_NOEC(h107, 107);
	TRAPHANDLER_NOEC(h108, 108);
	TRAPHANDLER_NOEC(h109, 109);
	TRAPHANDLER_NOEC(h110, 110);
	TRAPHANDLER_NOEC(h111, 111);
	TRAPHANDLER_NOEC(h112, 112);
	TRAPHANDLER_NOEC(h113, 113);
	TRAPHANDLER_NOEC(h114, 114);
	TRAPHANDLER_NOEC(h115, 115);
	TRAPHANDLER_NOEC(h116, 116);
	TRAPHANDLER_NOEC(h117, 117);
	TRAPHANDLER_NOEC(h118, 118);
	TRAPHANDLER_NOEC(h119, 119);
	TRAPHANDLER_NOEC(h120, 120);
	TRAPHANDLER_NOEC(h121, 121);
	TRAPHANDLER_NOEC(h122, 122);
	TRAPHANDLER_NOEC(h123, 123);
	TRAPHANDLER_NOEC(h124, 124);
	TRAPHANDLER_NOEC(h125, 125);
	TRAPHANDLER_NOEC(h126, 126);
	TRAPHANDLER_NOEC(h127, 127);
	TRAPHANDLER_NOEC(h128, 128);
	TRAPHANDLER_NOEC(h129, 129);
	TRAPHANDLER_NOEC(h130, 130);
	TRAPHANDLER_NOEC(h131, 131);
	TRAPHANDLER_NOEC(h132, 132);
	TRAPHANDLER_NOEC(h133, 133);
	TRAPHANDLER_NOEC(h134, 134);
	TRAPHANDLER_NOEC(h135, 135);
	TRAPHANDLER_NOEC(h136, 136);
	TRAPHANDLER_NOEC(h137, 137);
	TRAPHANDLER_NOEC(h138, 138);
	TRAPHANDLER_NOEC(h139, 139);
	TRAPHANDLER_NOEC(h140, 140);
	TRAPHANDLER_NOEC(h141, 141);
	TRAPHANDLER_NOEC(h142, 142);
	TRAPHANDLER_NOEC(h143, 143);
	TRAPHANDLER_NOEC(h144, 144);
	TRAPHANDLER_NOEC(h145, 145);
	TRAPHANDLER_NOEC(h146, 146);
	TRAPHANDLER_NOEC(h147, 147);
	TRAPHANDLER_NOEC(h148, 148);
	TRAPHANDLER_NOEC(h149, 149);
	TRAPHANDLER_NOEC(h150, 150);
	TRAPHANDLER_NOEC(h151, 151);
	TRAPHANDLER_NOEC(h152, 152);
	TRAPHANDLER_NOEC(h153, 153);
	TRAPHANDLER_NOEC(h154, 154);
	TRAPHANDLER_NOEC(h155, 155);
	TRAPHANDLER_NOEC(h156, 156);
	TRAPHANDLER_NOEC(h157, 157);
	TRAPHANDLER_NOEC(h158, 158);
	TRAPHANDLER_NOEC(h159, 159);
	TRAPHANDLER_NOEC(h160, 160);
	TRAPHANDLER_NOEC(h161, 161);
	TRAPHANDLER_NOEC(h162, 162);
	TRAPHANDLER_NOEC(h163, 163);
	TRAPHANDLER_NOEC(h164, 164);
	TRAPHANDLER_NOEC(h165, 165);
	TRAPHANDLER_NOEC(h166, 166);
	TRAPHANDLER_NOEC(h167, 167);
	TRAPHANDLER_NOEC(h168, 168);
	TRAPHANDLER_NOEC(h169, 169);
	TRAPHANDLER_NOEC(h170, 170);
	TRAPHANDLER_NOEC(h171, 171);
	TRAPHANDLER_NOEC(h172, 172);
	TRAPHANDLER_NOEC(h173, 173);
	TRAPHANDLER_NOEC(h174, 174);
	TRAPHANDLER_NOEC(h175, 175);
	TRAPHANDLER_NOEC(h176, 176);
	TRAPHANDLER_NOEC(h177, 177);
	TRAPHANDLER_NOEC(h178, 178);
	TRAPHANDLER_NOEC(h179, 179);
	TRAPHANDLER_NOEC(h180, 180);
	TRAPHANDLER_NOEC(h181, 181);
	TRAPHANDLER_NOEC(h182, 182);
	TRAPHANDLER_NOEC(h183, 183);
	TRAPHANDLER_NOEC(h184, 184);
	TRAPHANDLER_NOEC(h185, 185);
	TRAPHANDLER_NOEC(h186, 186);
	TRAPHANDLER_NOEC(h187, 187);
	TRAPHANDLER_NOEC(h188, 188);
	TRAPHANDLER_NOEC(h189, 189);
	TRAPHANDLER_NOEC(h190, 190);
	TRAPHANDLER_NOEC(h191, 191);
	TRAPHANDLER_NOEC(h192, 192);
	TRAPHANDLER_NOEC(h193, 193);
	TRAPHANDLER_NOEC(h194, 194);
	TRAPHANDLER_NOEC(h195, 195);
	TRAPHANDLER_NOEC(h196, 196);
	TRAPHANDLER_NOEC(h197, 197);
	TRAPHANDLER_NOEC(h198, 198);
	TRAPHANDLER_NOEC(h199, 199);
	TRAPHANDLER_NOEC(h200, 200);
	TRAPHANDLER_NOEC(h201, 201);
	TRAPHANDLER_NOEC(h202, 202);
	TRAPHANDLER_NOEC(h203, 203);
	TRAPHANDLER_NOEC(h204, 204);
	TRAPHANDLER_NOEC(h205, 205);
	TRAPHANDLER_NOEC(h206, 206);
	TRAPHANDLER_NOEC(h207, 207);
	TRAPHANDLER_NOEC(h208, 208);
	TRAPHANDLER_NOEC(h209, 209);
	TRAPHANDLER_NOEC(h210, 210);
	TRAPHANDLER_NOEC(h211, 211);
	TRAPHANDLER_NOEC(h212, 212);
	TRAPHANDLER_NOEC(h213, 213);
	TRAPHANDLER_NOEC(h214, 214);
	TRAPHANDLER_NOEC(h215, 215);
	TRAPHANDLER_NOEC(h216, 216);
	TRAPHANDLER_NOEC(h217, 217);
	TRAPHANDLER_NOEC(h218, 218);
	TRAPHANDLER_NOEC(h219, 219);
	TRAPHANDLER_NOEC(h220, 220);
	TRAPHANDLER_NOEC(h221, 221);
	TRAPHANDLER_NOEC(h222, 222);
	TRAPHANDLER_NOEC(h223, 223);
	TRAPHANDLER_NOEC(h224, 224);
	TRAPHANDLER_NOEC(h225, 225);
	TRAPHANDLER_NOEC(h226, 226);
	TRAPHANDLER_NOEC(h227, 227);
	TRAPHANDLER_NOEC(h228, 228);
	TRAPHANDLER_NOEC(h229, 229);
	TRAPHANDLER_NOEC(h230, 230);
	TRAPHANDLER_NOEC(h231, 231);
	TRAPHANDLER_NOEC(h232, 232);
	TRAPHANDLER_NOEC(h233, 233);
	TRAPHANDLER_NOEC(h234, 234);
	TRAPHANDLER_NOEC(h235, 235);
	TRAPHANDLER_NOEC(h236, 236);
	TRAPHANDLER_NOEC(h237, 237);
	TRAPHANDLER_NOEC(h238, 238);
	TRAPHANDLER_NOEC(h239, 239);
	TRAPHANDLER_NOEC(h240, 240);
	TRAPHANDLER_NOEC(h241, 241);
	TRAPHANDLER_NOEC(h242, 242);
	TRAPHANDLER_NOEC(h243, 243);
	TRAPHANDLER_NOEC(h244, 244);
	TRAPHANDLER_NOEC(h245, 245);
	TRAPHANDLER_NOEC(h246, 246);
	TRAPHANDLER_NOEC(h247, 247);
	TRAPHANDLER_NOEC(h248, 248);
	TRAPHANDLER_NOEC(h249, 249);
	TRAPHANDLER_NOEC(h250, 250);
	TRAPHANDLER_NOEC(h251, 251);
	TRAPHANDLER_NOEC(h252, 252);
	TRAPHANDLER_NOEC(h253, 253);
	TRAPHANDLER_NOEC(h254, 254);
	TRAPHANDLER_NOEC(h255, 255);

.data
.globl hd
hd:
	.long h0
	.long h1
	.long h2
	.long h3
	.long h4
	.long h5
	.long h6
	.long h7
	.long h8
	.long h9
	.long h10
	.long h11
	.long h12
	.long h13
	.long h14
	.long h15
	.long h16
	.long h17
	.long h18
	.long h19
	.long h20
	.long h21
	.long h22
	.long h23
	.long h24
	.long h25
	.long h26
	.long h27
	.long h28
	.long h29
	.long h30
	.long h31
	.long h32
	.long h33
	.long h34
	.long h35
	.long h36
	.long h37
	.long h38
	.long h39
	.long h40
	.long h41
	.long h42
	.long h43
	.long h44
	.long h45
	.long h46
	.long h47
	.long h48
	.long h49
	.long h50
	.long h51
	.long h52
	.long h53
	.long h54
	.long h55
	.long h56
	.long h57
	.long h58
	.long h59
	.long h60
	.long h61
	.long h62
	.long h63
	.long h64
	.long h65
	.long h66
	.long h67
	.long h68
	.long h69
	.long h70
	.long h71
	.long h72
	.long h73
	.long h74
	.long h75
	.long h76
	.long h77
	.long h78
	.long h79
	.long h80
	.long h81
	.long h82
	.long h83
	.long h84
	.long h85
	.long h86
	.long h87
	.long h88
	.long h89
	.long h90
	.long h91
	.long h92
	.long h93
	.long h94
	.long h95
	.long h96
	.long h97
	.long h98
	.long h99
	.long h100
	.long h101
	.long h102
	.long h103
	.long h104
	.long h105
	.long h106
	.long h107
	.long h108
	.long h109
	.long h110
	.long h111
	.long h112
	.long h113
	.long h114
	.long h115
	.long h116
	.long h117
	.long h118
	.long h119
	.long h120
	.long h121
	.long h122
	.long h123
	.long h124
	.long h125
	.long h126
	.long h127
	.long h128
	.long h129
	.long h130
	.long h131
	.long h132
	.long h133
	.long h134
	.long h135
	.long h136
	.long h137
	.long h138
	.long h139
	.long h140
	.long h141
	.long h142
	.long h143
	.long h144
	.long h145
	.long h146
	.long h147
	.long h148
	.long h149
	.long h150
	.long h151
	.long h152
	.long h153
	.long h154
	.long h155
	.long h156
	.long h157
	.long h158
	.long h159
	.long h160
	.long h161
	.long h162
	.long h163
	.long h164
	.long h165
	.long h166
	.long h167
	.long h168
	.long h169
	.long h170
	.long h171
	.long h172
	.long h173
	.long h174
	.long h175
	.long h176
	.long h177
	.long h178
	.long h179
	.long h180
	.long h181
	.long h182
	.long h183
	.long h184
	.long h185
	.long h186
	.long h187
	.long h188
	.long h189
	.long h190
	.long h191
	.long h192
	.long h193
	.long h194
	.long h195
	.long h196
	.long h197
	.long h198
	.long h199
	.long h200
	.long h201
	.long h202
	.long h203
	.long h204
	.long h205
	.long h206
	.long h207
	.long h208
	.long h209
	.long h210
	.long h211
	.long h212
	.long h213
	.long h214
	.long h215
	.long h216
	.long h217
	.long h218
	.long h219
	.long h220
	.long h221
	.long h222
	.long h223
	.long h224
	.long h225
	.long h226
	.long h227
	.long h228
	.long h229
	.long h230
	.long h231
	.long h232
	.long h233
	.long h234
	.long h235
	.long h236
	.long h237
	.long h238
	.long h239
	.long h240
	.long h241
	.long h242
	.long h243
	.long h244
	.long h245
	.long h246
	.long h247
	.long h248
	.long h249
	.long h250
	.long h251
	.long h252
	.long h253
	.long h254
	.long h255




.text 
.globl _alltraps
_alltraps:
	pushl %ds
	pushl %es
	pushal
	movl GD_KD, %eax
	movl %eax, %ds
	movl %eax, %es
	pushl %esp
	call trap

.text
.globl clock_thdlr
.type clock_thdlr, @function;
.align 2;
clock_thdlr:
	movb $1, in_intr
	popl intr_ret_eip
	popl intr_cs
	popl intr_eflags
	movl %ebp, intr_ebp_reg
	movl %esp, intr_esp_reg
	movl $0x0,%ebp
	movl $(bootstacktop),%esp
	pushl $GD_KD
	pushl intr_esp_reg
	pushl intr_eflags
	pushl intr_cs
	pushl intr_ret_eip
	pushl $0
	pushl $(IRQ_OFFSET + IRQ_CLOCK)
	pushl %ds
        pushl %es

	pushl %eax
	pushl %ecx
	pushl %edx
	pushl %ebx
	pushl intr_esp_reg
	pushl intr_ebp_reg
	pushl %esi
	pushl %edi

        pushl %esp  /* trap(%esp) */
        call trap
loop3:	jmp loop3

