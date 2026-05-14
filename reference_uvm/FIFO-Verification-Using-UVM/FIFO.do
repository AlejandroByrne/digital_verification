vlib work
vlog -f FIFO_list.txt +cover -covercells 
vsim -voptargs=+acc work.top -cover 
add wave /top/FIFO_Vif/*
coverage save top.ucdb -onexit
run -all