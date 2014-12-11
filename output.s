.data

	n: 		.word 0
	res: 		.word 0
	i: 		.word 0
	_tmp_1: 		.word 10
	_tmp_2: 		.word 1
	_tmp_3: 		.word 1
	_tmp_4: 		.word 0
.text

main:
label1:
	lw	$t0, _tmp_1
	sw 	$t0, n
label2:
	lw	$t0, _tmp_2
	sw 	$t0, res
label3:
	lw	$t0, _tmp_3
	sw 	$t0, i
label4:
	lw	$t0, i
	lw	$t1, n
	ble 	$t0, $t1, label6
label5:
	j 	label10
label6:
	lw	$t0, res
	lw	$t1, i
	mul 	$t2, $t0, $t1
	sw 	$t2, _tmp_4
label7:
	lw	$t0, _tmp_4
	sw 	$t0, res
label8:
	lw	$t0, i
	li 	$t1, 1
	add 	$t2, $t0, $t1
	sw 	$t2, i
label9:
	j 	label4
label10:
	lw 	$a0, res
	li 	$v0, 1
	syscall
label11:
	li 	$v0, 10
	syscall
