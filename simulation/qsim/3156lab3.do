onerror {quit -f}
vlib work
vlog -work work 3156lab3.vo
vlog -work work 3156lab3.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.3156lab3_vlg_vec_tst
vcd file -direction 3156lab3.msim.vcd
vcd add -internal 3156lab3_vlg_vec_tst/*
vcd add -internal 3156lab3_vlg_vec_tst/i1/*
add wave /*
run -all
