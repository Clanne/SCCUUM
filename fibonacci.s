.data

	n: 		.word 0
	_tmp_6: 		.word 0
	_tmp_7: 		.word 0
	fib1: 		.word 0
	i: 		.word 0
	fib2: 		.word 0
	tmp: 		.word 0
.text

main:
label1:
	li	$t0, 10
	sw 	$t0, n
label2:
	li	$t0, 1
	sw 	$t0, fib1
label3:
	li	$t0, 1
	sw 	$t0, fib2
label4:
	li	$t0, 1
	sw 	$t0, i
label5:
	lw	$t0, i
	lw	$t1, n
	blt 	$t0, $t1, label10
label6:
	j 	label15
label7:
	lw	$t0, i
	li	$t1, 1
	add 	$t2, $t0, $t1
	sw 	$t2, _tmp_6
label8:
	lw	$t0, _tmp_6
	sw 	$t0, i
label9:
	j 	label5
label10:
	lw	$t0, fib1
	sw 	$t0, tmp
label11:
	lw	$t0, fib2
	sw 	$t0, fib1
label12:
	lw	$t0, fib2
	lw	$t1, tmp
	add 	$t2, $t0, $t1
	sw 	$t2, _tmp_7
label13:
	lw	$t0, _tmp_7
	sw 	$t0, fib2
label14:
	j 	label7
label15:
	lw 	$a0, fib2
	li 	$v0, 1
	syscall
label16:
	li 	$v0, 10
	syscall
