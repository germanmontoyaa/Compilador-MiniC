##################
# Seccion de datos
	.data
_n:
	.word 0
_N:
	.word 0
_a:
	.word 0
_b:
	.word 0
_c:
	.word 0
$str1:
	.asciiz "Introduce una n:"
$str2:
	.asciiz "\n"
##################
# Seccion de codigo
	.text
	.globl main
main:
	la $a0,$str1
	li $v0,4
	syscall
	li $v0,5
	syscall
	sw $v0,_N
	li $t0,2
	sw $t0,_n
	li $t0,0
	sw $t0,_c
	li $t0,1
	sw $t0,_b
	li $t0,1
	sw $t0,_n
$l1:
	lw $t0,_n
	lw $t1,_N
	slt $t2,$t0,$t1
	beqz $t2,$l2
	lw $t0,_b
	lw $t1,_c
	add $t2,$t0,$t1
	sw $t2,_a
	lw $t0,_b
	sw $t0,_c
	lw $t0,_a
	sw $t0,_b
	lw $t0,_n
	li $t1,1
	add $t2,$t0,$t1
	sw $t2,_n
	b $l1
$l2:
	lw $t0,_a
	move $a0,$t0
	li $v0,1
	syscall
	la $a0,$str2
	li $v0,4
	syscall
##############
# Fin
	li $v0, 10
	syscall
