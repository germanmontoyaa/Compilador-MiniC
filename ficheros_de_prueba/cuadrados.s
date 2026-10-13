##################
# Seccion de datos
	.data
_a:
	.word 0
_i:
	.word 0
_j:
	.word 0
$str1:
	.asciiz "\n"
##################
# Seccion de codigo
	.text
	.globl main
main:
	li $t0,5
	sw $t0,_a
	li $t0,0
	sw $t0,_i
$l1:
	li $v0,5
	syscall
	sw $v0,_j
	lw $t0,_j
	lw $t1,_j
	mul $t2,$t0,$t1
	move $a0,$t2
	li $v0,1
	syscall
	la $a0,$str1
	li $v0,4
	syscall
	lw $t0,_i
	li $t1,1
	add $t2,$t0,$t1
	sw $t2,_i
	lw $t0,_i
	lw $t1,_a
	slt $t2,$t0,$t1
	bnez $t2,$l1
##############
# Fin
	li $v0, 10
	syscall
