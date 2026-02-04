create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]

# clock
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets clk_IBUF_BUFG]

# probe0: r0 (zero)
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/r0[0]} {u_irq_cpu/u_cpu/dp/regfile/r0[1]} {u_irq_cpu/u_cpu/dp/regfile/r0[2]} {u_irq_cpu/u_cpu/dp/regfile/r0[3]} {u_irq_cpu/u_cpu/dp/regfile/r0[4]} {u_irq_cpu/u_cpu/dp/regfile/r0[5]} {u_irq_cpu/u_cpu/dp/regfile/r0[6]} {u_irq_cpu/u_cpu/dp/regfile/r0[7]} {u_irq_cpu/u_cpu/dp/regfile/r0[8]} {u_irq_cpu/u_cpu/dp/regfile/r0[9]} {u_irq_cpu/u_cpu/dp/regfile/r0[10]} {u_irq_cpu/u_cpu/dp/regfile/r0[11]} {u_irq_cpu/u_cpu/dp/regfile/r0[12]} {u_irq_cpu/u_cpu/dp/regfile/r0[13]} {u_irq_cpu/u_cpu/dp/regfile/r0[14]} {u_irq_cpu/u_cpu/dp/regfile/r0[15]}]]

# probe1: a0 / v0 (r1)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/a0[0]} {u_irq_cpu/u_cpu/dp/regfile/a0[1]} {u_irq_cpu/u_cpu/dp/regfile/a0[2]} {u_irq_cpu/u_cpu/dp/regfile/a0[3]} {u_irq_cpu/u_cpu/dp/regfile/a0[4]} {u_irq_cpu/u_cpu/dp/regfile/a0[5]} {u_irq_cpu/u_cpu/dp/regfile/a0[6]} {u_irq_cpu/u_cpu/dp/regfile/a0[7]} {u_irq_cpu/u_cpu/dp/regfile/a0[8]} {u_irq_cpu/u_cpu/dp/regfile/a0[9]} {u_irq_cpu/u_cpu/dp/regfile/a0[10]} {u_irq_cpu/u_cpu/dp/regfile/a0[11]} {u_irq_cpu/u_cpu/dp/regfile/a0[12]} {u_irq_cpu/u_cpu/dp/regfile/a0[13]} {u_irq_cpu/u_cpu/dp/regfile/a0[14]} {u_irq_cpu/u_cpu/dp/regfile/a0[15]}]]

# probe2: a1 / v1 (r2)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/a1[0]} {u_irq_cpu/u_cpu/dp/regfile/a1[1]} {u_irq_cpu/u_cpu/dp/regfile/a1[2]} {u_irq_cpu/u_cpu/dp/regfile/a1[3]} {u_irq_cpu/u_cpu/dp/regfile/a1[4]} {u_irq_cpu/u_cpu/dp/regfile/a1[5]} {u_irq_cpu/u_cpu/dp/regfile/a1[6]} {u_irq_cpu/u_cpu/dp/regfile/a1[7]} {u_irq_cpu/u_cpu/dp/regfile/a1[8]} {u_irq_cpu/u_cpu/dp/regfile/a1[9]} {u_irq_cpu/u_cpu/dp/regfile/a1[10]} {u_irq_cpu/u_cpu/dp/regfile/a1[11]} {u_irq_cpu/u_cpu/dp/regfile/a1[12]} {u_irq_cpu/u_cpu/dp/regfile/a1[13]} {u_irq_cpu/u_cpu/dp/regfile/a1[14]} {u_irq_cpu/u_cpu/dp/regfile/a1[15]}]]

# probe3: a2 (r3)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/a2[0]} {u_irq_cpu/u_cpu/dp/regfile/a2[1]} {u_irq_cpu/u_cpu/dp/regfile/a2[2]} {u_irq_cpu/u_cpu/dp/regfile/a2[3]} {u_irq_cpu/u_cpu/dp/regfile/a2[4]} {u_irq_cpu/u_cpu/dp/regfile/a2[5]} {u_irq_cpu/u_cpu/dp/regfile/a2[6]} {u_irq_cpu/u_cpu/dp/regfile/a2[7]} {u_irq_cpu/u_cpu/dp/regfile/a2[8]} {u_irq_cpu/u_cpu/dp/regfile/a2[9]} {u_irq_cpu/u_cpu/dp/regfile/a2[10]} {u_irq_cpu/u_cpu/dp/regfile/a2[11]} {u_irq_cpu/u_cpu/dp/regfile/a2[12]} {u_irq_cpu/u_cpu/dp/regfile/a2[13]} {u_irq_cpu/u_cpu/dp/regfile/a2[14]} {u_irq_cpu/u_cpu/dp/regfile/a2[15]}]]

# probe4: t0 (r4)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/t0[0]} {u_irq_cpu/u_cpu/dp/regfile/t0[1]} {u_irq_cpu/u_cpu/dp/regfile/t0[2]} {u_irq_cpu/u_cpu/dp/regfile/t0[3]} {u_irq_cpu/u_cpu/dp/regfile/t0[4]} {u_irq_cpu/u_cpu/dp/regfile/t0[5]} {u_irq_cpu/u_cpu/dp/regfile/t0[6]} {u_irq_cpu/u_cpu/dp/regfile/t0[7]} {u_irq_cpu/u_cpu/dp/regfile/t0[8]} {u_irq_cpu/u_cpu/dp/regfile/t0[9]} {u_irq_cpu/u_cpu/dp/regfile/t0[10]} {u_irq_cpu/u_cpu/dp/regfile/t0[11]} {u_irq_cpu/u_cpu/dp/regfile/t0[12]} {u_irq_cpu/u_cpu/dp/regfile/t0[13]} {u_irq_cpu/u_cpu/dp/regfile/t0[14]} {u_irq_cpu/u_cpu/dp/regfile/t0[15]}]]

# probe5: t1 (r5)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/t1[0]} {u_irq_cpu/u_cpu/dp/regfile/t1[1]} {u_irq_cpu/u_cpu/dp/regfile/t1[2]} {u_irq_cpu/u_cpu/dp/regfile/t1[3]} {u_irq_cpu/u_cpu/dp/regfile/t1[4]} {u_irq_cpu/u_cpu/dp/regfile/t1[5]} {u_irq_cpu/u_cpu/dp/regfile/t1[6]} {u_irq_cpu/u_cpu/dp/regfile/t1[7]} {u_irq_cpu/u_cpu/dp/regfile/t1[8]} {u_irq_cpu/u_cpu/dp/regfile/t1[9]} {u_irq_cpu/u_cpu/dp/regfile/t1[10]} {u_irq_cpu/u_cpu/dp/regfile/t1[11]} {u_irq_cpu/u_cpu/dp/regfile/t1[12]} {u_irq_cpu/u_cpu/dp/regfile/t1[13]} {u_irq_cpu/u_cpu/dp/regfile/t1[14]} {u_irq_cpu/u_cpu/dp/regfile/t1[15]}]]

# probe6: t2 (r6)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/t2[0]} {u_irq_cpu/u_cpu/dp/regfile/t2[1]} {u_irq_cpu/u_cpu/dp/regfile/t2[2]} {u_irq_cpu/u_cpu/dp/regfile/t2[3]} {u_irq_cpu/u_cpu/dp/regfile/t2[4]} {u_irq_cpu/u_cpu/dp/regfile/t2[5]} {u_irq_cpu/u_cpu/dp/regfile/t2[6]} {u_irq_cpu/u_cpu/dp/regfile/t2[7]} {u_irq_cpu/u_cpu/dp/regfile/t2[8]} {u_irq_cpu/u_cpu/dp/regfile/t2[9]} {u_irq_cpu/u_cpu/dp/regfile/t2[10]} {u_irq_cpu/u_cpu/dp/regfile/t2[11]} {u_irq_cpu/u_cpu/dp/regfile/t2[12]} {u_irq_cpu/u_cpu/dp/regfile/t2[13]} {u_irq_cpu/u_cpu/dp/regfile/t2[14]} {u_irq_cpu/u_cpu/dp/regfile/t2[15]}]]

# probe7: t3 (r7)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/t3[0]} {u_irq_cpu/u_cpu/dp/regfile/t3[1]} {u_irq_cpu/u_cpu/dp/regfile/t3[2]} {u_irq_cpu/u_cpu/dp/regfile/t3[3]} {u_irq_cpu/u_cpu/dp/regfile/t3[4]} {u_irq_cpu/u_cpu/dp/regfile/t3[5]} {u_irq_cpu/u_cpu/dp/regfile/t3[6]} {u_irq_cpu/u_cpu/dp/regfile/t3[7]} {u_irq_cpu/u_cpu/dp/regfile/t3[8]} {u_irq_cpu/u_cpu/dp/regfile/t3[9]} {u_irq_cpu/u_cpu/dp/regfile/t3[10]} {u_irq_cpu/u_cpu/dp/regfile/t3[11]} {u_irq_cpu/u_cpu/dp/regfile/t3[12]} {u_irq_cpu/u_cpu/dp/regfile/t3[13]} {u_irq_cpu/u_cpu/dp/regfile/t3[14]} {u_irq_cpu/u_cpu/dp/regfile/t3[15]}]]

# probe8: s0 (r8)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 16 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/s0[0]} {u_irq_cpu/u_cpu/dp/regfile/s0[1]} {u_irq_cpu/u_cpu/dp/regfile/s0[2]} {u_irq_cpu/u_cpu/dp/regfile/s0[3]} {u_irq_cpu/u_cpu/dp/regfile/s0[4]} {u_irq_cpu/u_cpu/dp/regfile/s0[5]} {u_irq_cpu/u_cpu/dp/regfile/s0[6]} {u_irq_cpu/u_cpu/dp/regfile/s0[7]} {u_irq_cpu/u_cpu/dp/regfile/s0[8]} {u_irq_cpu/u_cpu/dp/regfile/s0[9]} {u_irq_cpu/u_cpu/dp/regfile/s0[10]} {u_irq_cpu/u_cpu/dp/regfile/s0[11]} {u_irq_cpu/u_cpu/dp/regfile/s0[12]} {u_irq_cpu/u_cpu/dp/regfile/s0[13]} {u_irq_cpu/u_cpu/dp/regfile/s0[14]} {u_irq_cpu/u_cpu/dp/regfile/s0[15]}]]

# probe9: s1 (r9)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/s1[0]} {u_irq_cpu/u_cpu/dp/regfile/s1[1]} {u_irq_cpu/u_cpu/dp/regfile/s1[2]} {u_irq_cpu/u_cpu/dp/regfile/s1[3]} {u_irq_cpu/u_cpu/dp/regfile/s1[4]} {u_irq_cpu/u_cpu/dp/regfile/s1[5]} {u_irq_cpu/u_cpu/dp/regfile/s1[6]} {u_irq_cpu/u_cpu/dp/regfile/s1[7]} {u_irq_cpu/u_cpu/dp/regfile/s1[8]} {u_irq_cpu/u_cpu/dp/regfile/s1[9]} {u_irq_cpu/u_cpu/dp/regfile/s1[10]} {u_irq_cpu/u_cpu/dp/regfile/s1[11]} {u_irq_cpu/u_cpu/dp/regfile/s1[12]} {u_irq_cpu/u_cpu/dp/regfile/s1[13]} {u_irq_cpu/u_cpu/dp/regfile/s1[14]} {u_irq_cpu/u_cpu/dp/regfile/s1[15]}]]

# probe10: s2 (r10)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 16 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/s2[0]} {u_irq_cpu/u_cpu/dp/regfile/s2[1]} {u_irq_cpu/u_cpu/dp/regfile/s2[2]} {u_irq_cpu/u_cpu/dp/regfile/s2[3]} {u_irq_cpu/u_cpu/dp/regfile/s2[4]} {u_irq_cpu/u_cpu/dp/regfile/s2[5]} {u_irq_cpu/u_cpu/dp/regfile/s2[6]} {u_irq_cpu/u_cpu/dp/regfile/s2[7]} {u_irq_cpu/u_cpu/dp/regfile/s2[8]} {u_irq_cpu/u_cpu/dp/regfile/s2[9]} {u_irq_cpu/u_cpu/dp/regfile/s2[10]} {u_irq_cpu/u_cpu/dp/regfile/s2[11]} {u_irq_cpu/u_cpu/dp/regfile/s2[12]} {u_irq_cpu/u_cpu/dp/regfile/s2[13]} {u_irq_cpu/u_cpu/dp/regfile/s2[14]} {u_irq_cpu/u_cpu/dp/regfile/s2[15]}]]

# probe11: s3 (r11)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/s3[0]} {u_irq_cpu/u_cpu/dp/regfile/s3[1]} {u_irq_cpu/u_cpu/dp/regfile/s3[2]} {u_irq_cpu/u_cpu/dp/regfile/s3[3]} {u_irq_cpu/u_cpu/dp/regfile/s3[4]} {u_irq_cpu/u_cpu/dp/regfile/s3[5]} {u_irq_cpu/u_cpu/dp/regfile/s3[6]} {u_irq_cpu/u_cpu/dp/regfile/s3[7]} {u_irq_cpu/u_cpu/dp/regfile/s3[8]} {u_irq_cpu/u_cpu/dp/regfile/s3[9]} {u_irq_cpu/u_cpu/dp/regfile/s3[10]} {u_irq_cpu/u_cpu/dp/regfile/s3[11]} {u_irq_cpu/u_cpu/dp/regfile/s3[12]} {u_irq_cpu/u_cpu/dp/regfile/s3[13]} {u_irq_cpu/u_cpu/dp/regfile/s3[14]} {u_irq_cpu/u_cpu/dp/regfile/s3[15]}]]

# probe12: fp (r12)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 16 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/fp[0]} {u_irq_cpu/u_cpu/dp/regfile/fp[1]} {u_irq_cpu/u_cpu/dp/regfile/fp[2]} {u_irq_cpu/u_cpu/dp/regfile/fp[3]} {u_irq_cpu/u_cpu/dp/regfile/fp[4]} {u_irq_cpu/u_cpu/dp/regfile/fp[5]} {u_irq_cpu/u_cpu/dp/regfile/fp[6]} {u_irq_cpu/u_cpu/dp/regfile/fp[7]} {u_irq_cpu/u_cpu/dp/regfile/fp[8]} {u_irq_cpu/u_cpu/dp/regfile/fp[9]} {u_irq_cpu/u_cpu/dp/regfile/fp[10]} {u_irq_cpu/u_cpu/dp/regfile/fp[11]} {u_irq_cpu/u_cpu/dp/regfile/fp[12]} {u_irq_cpu/u_cpu/dp/regfile/fp[13]} {u_irq_cpu/u_cpu/dp/regfile/fp[14]} {u_irq_cpu/u_cpu/dp/regfile/fp[15]}]]

# probe13: sp (r13)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 16 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/sp[0]} {u_irq_cpu/u_cpu/dp/regfile/sp[1]} {u_irq_cpu/u_cpu/dp/regfile/sp[2]} {u_irq_cpu/u_cpu/dp/regfile/sp[3]} {u_irq_cpu/u_cpu/dp/regfile/sp[4]} {u_irq_cpu/u_cpu/dp/regfile/sp[5]} {u_irq_cpu/u_cpu/dp/regfile/sp[6]} {u_irq_cpu/u_cpu/dp/regfile/sp[7]} {u_irq_cpu/u_cpu/dp/regfile/sp[8]} {u_irq_cpu/u_cpu/dp/regfile/sp[9]} {u_irq_cpu/u_cpu/dp/regfile/sp[10]} {u_irq_cpu/u_cpu/dp/regfile/sp[11]} {u_irq_cpu/u_cpu/dp/regfile/sp[12]} {u_irq_cpu/u_cpu/dp/regfile/sp[13]} {u_irq_cpu/u_cpu/dp/regfile/sp[14]} {u_irq_cpu/u_cpu/dp/regfile/sp[15]}]]

# probe14: lr (r14)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 16 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/lr[0]} {u_irq_cpu/u_cpu/dp/regfile/lr[1]} {u_irq_cpu/u_cpu/dp/regfile/lr[2]} {u_irq_cpu/u_cpu/dp/regfile/lr[3]} {u_irq_cpu/u_cpu/dp/regfile/lr[4]} {u_irq_cpu/u_cpu/dp/regfile/lr[5]} {u_irq_cpu/u_cpu/dp/regfile/lr[6]} {u_irq_cpu/u_cpu/dp/regfile/lr[7]} {u_irq_cpu/u_cpu/dp/regfile/lr[8]} {u_irq_cpu/u_cpu/dp/regfile/lr[9]} {u_irq_cpu/u_cpu/dp/regfile/lr[10]} {u_irq_cpu/u_cpu/dp/regfile/lr[11]} {u_irq_cpu/u_cpu/dp/regfile/lr[12]} {u_irq_cpu/u_cpu/dp/regfile/lr[13]} {u_irq_cpu/u_cpu/dp/regfile/lr[14]} {u_irq_cpu/u_cpu/dp/regfile/lr[15]}]]

# probe15: gp (r15)
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 16 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {u_irq_cpu/u_cpu/dp/regfile/gp[0]} {u_irq_cpu/u_cpu/dp/regfile/gp[1]} {u_irq_cpu/u_cpu/dp/regfile/gp[2]} {u_irq_cpu/u_cpu/dp/regfile/gp[3]} {u_irq_cpu/u_cpu/dp/regfile/gp[4]} {u_irq_cpu/u_cpu/dp/regfile/gp[5]} {u_irq_cpu/u_cpu/dp/regfile/gp[6]} {u_irq_cpu/u_cpu/dp/regfile/gp[7]} {u_irq_cpu/u_cpu/dp/regfile/gp[8]} {u_irq_cpu/u_cpu/dp/regfile/gp[9]} {u_irq_cpu/u_cpu/dp/regfile/gp[10]} {u_irq_cpu/u_cpu/dp/regfile/gp[11]} {u_irq_cpu/u_cpu/dp/regfile/gp[12]} {u_irq_cpu/u_cpu/dp/regfile/gp[13]} {u_irq_cpu/u_cpu/dp/regfile/gp[14]} {u_irq_cpu/u_cpu/dp/regfile/gp[15]}]]

# dbg_hub settings (unchanged)
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]

# extra trigger: register file write-enable
create_debug_port u_ila_0 probe
set_property PROBE_TYPE TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets u_irq_cpu/u_cpu/rf_we_final]

# pc probe 
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 16 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {u_irq_cpu/u_cpu/dp/pc[0]} {u_irq_cpu/u_cpu/dp/pc[1]} {u_irq_cpu/u_cpu/dp/pc[2]} {u_irq_cpu/u_cpu/dp/pc[3]} {u_irq_cpu/u_cpu/dp/pc[4]} {u_irq_cpu/u_cpu/dp/pc[5]} {u_irq_cpu/u_cpu/dp/pc[6]} {u_irq_cpu/u_cpu/dp/pc[7]} {u_irq_cpu/u_cpu/dp/pc[8]} {u_irq_cpu/u_cpu/dp/pc[9]} {u_irq_cpu/u_cpu/dp/pc[10]} {u_irq_cpu/u_cpu/dp/pc[11]} {u_irq_cpu/u_cpu/dp/pc[12]} {u_irq_cpu/u_cpu/dp/pc[13]} {u_irq_cpu/u_cpu/dp/pc[14]} {u_irq_cpu/u_cpu/dp/pc[15]}]]

# irq take probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets u_periph/irq_take]

# int en probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets u_irq_cpu/u_cpu/int_en]

# irq vector probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 16 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {u_irq_cpu/u_cpu/irq_vector[0]} {u_irq_cpu/u_cpu/irq_vector[1]} {u_irq_cpu/u_cpu/irq_vector[2]} {u_irq_cpu/u_cpu/irq_vector[3]} {u_irq_cpu/u_cpu/irq_vector[4]} {u_irq_cpu/u_cpu/irq_vector[5]} {u_irq_cpu/u_cpu/irq_vector[6]} {u_irq_cpu/u_cpu/irq_vector[7]} {u_irq_cpu/u_cpu/irq_vector[8]} {u_irq_cpu/u_cpu/irq_vector[9]} {u_irq_cpu/u_cpu/irq_vector[10]} {u_irq_cpu/u_cpu/irq_vector[11]} {u_irq_cpu/u_cpu/irq_vector[12]} {u_irq_cpu/u_cpu/irq_vector[13]} {u_irq_cpu/u_cpu/irq_vector[14]} {u_irq_cpu/u_cpu/irq_vector[15]}]]

# timer 0 probe 
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets u_periph/u_timer/int_req_dbg]

# timer 1 probe
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets u_periph/u_timer1/int_req_dbg]