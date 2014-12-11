.data

	res: 		.word 0
	n: 		.word 0
	i: 		.word 0
	_tmp_4: 		.word 0
.text

main:
label1:
	li	$t0, 1
	sw 	$t0, res
label2:
	li	$t0, 10
	sw 	$t0, n
label3:
	li	$t0, 1
	sw 	$t0, i
label4:
	lw	$t0, i
	lw	$t1, n
	ble 	$t0, $t1, label8
label5:
	j 	label11
label6:
	lw	$t0, i
	li 	$t1, 1
	add 	$t2, $t0, $t1
	sw 	$t2, i
label7:
	j 	label4
label8:
	lw	$t0, res
	lw	$t1, i
	mul 	$t2, $t0, $t1
	sw 	$t2, _tmp_4
label9:
	lw	$t0, _tmp_4
	sw 	$t0, res
label10:
	j 	label6
label11:
	lw 	$a0, res
	li 	$v0, 1
	syscall
label12:
	li 	$v0, 10
	syscall
