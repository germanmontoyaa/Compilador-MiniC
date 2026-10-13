##################
# Seccion de datos
	.data
_c:
	.word 0
_d:
	.word 0
_i:
	.word 0
_j:
	.word 0
$str1:
	.asciiz "1 "
$str2:
	.asciiz "0 "
$str3:
	.asciiz "\n"
$str4:
	.asciiz "\n"
##################
# Seccion de codigo
	.text
	.globl main
main:
	li $t0,10
	sw $t0,_d
	li $t0,10
	sw $t0,_c
	li $t0,0
	sw $t0,_i
$l5:
	lw $t0,_i
	lw $t1,_c
	slt $t2,$t0,$t1
	beqz $t2,$l6
	li $t0,0
	sw $t0,_j
$l3:
	lw $t0,_j
	lw $t1,_d
	slt $t2,$t0,$t1
	beqz $t2,$l4
	lw $t0,_j
	lw $t1,_i
	seq $t2,$t0,$t1
	beqz $t2,$l1
	la $a0,$str1
	li $v0,4
	syscall
	b $l2
$l1:
	la $a0,$str2
	li $v0,4
	syscall
$l2:
	lw $t0,_j
	li $t1,1
	add $t2,$t0,$t1
	sw $t2,_j
	b $l3
$l4:
	la $a0,$str3
	li $v0,4
	syscall
	lw $t0,_i
	li $t1,1
	add $t2,$t0,$t1
	sw $t2,_i
	b $l5
$l6:
	la $a0,$str4
	li $v0,4
	syscall
##############
# Fin
	li $v0, 10
	syscall
