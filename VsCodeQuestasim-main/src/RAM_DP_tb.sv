// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "07/24/2018 13:23:39"
                                                                                
// Verilog Test Bench template for design : RAM_DP
// 
// Simulation tool : QuestaSim (Verilog)
// 

`timescale 1 ns/ 1 ps
module RAM_DP_vlg_tst();
// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg clock;
reg [7:0] data_in;
reg [4:0] rdaddress;
reg rden;
reg [4:0] wraddress;
reg wren;
// wires                                               
wire [7:0]  data_out;

// assign statements (if any)                          
RAM_DP i1 (
// port map - connection between master ports and signals/registers   
	.clock(clock),
	.data_in(data_in),
	.data_out(data_out),
	.rdaddress(rdaddress),
	.rden(rden),
	.wraddress(wraddress),
	.wren(wren)
);
initial                                                
begin   
clock=1'b0;                                               
forever # 10 clock=!clock;                    
end                
         
initial
begin
$display(" escribo unos valores");
solo_escritura(5'd7,25);
solo_escritura(5'd14,35);
$display("leo de la posicion 7");
solo_lectura(5'd7);
if (data_out!=25)
	$error("no funciona bien");
$display ("escribo y leo de la posicion 14");
lectura_escritura(5'd14,45);
if (data_out==35)
	$info("lee primero y escribe despues");
if (data_out==45)
	$error("MENSAJE_tb: escribe primero y lee despues");
if (data_out===8'bx)
	$error("CUIDADO: este dispositivo no parece que admita lectura y escritura simultanea");
solo_lectura(5'd14);
if (data_out!=45)
	$error("no funciona bien");
$stop;
end


                           
task solo_escritura( input [4:0] address, input [7:0] valor);
begin
rden<=1'b0;
wren<=1'b0;
@(posedge clock) 
wren<=1'b1;
wraddress<=address;
data_in<=valor;
@(posedge clock)
wren<=1'b0;
end

endtask
task solo_lectura( input [4:0] address);
begin
rden<=1'b0;
wren<=1'b0;
@(posedge clock) 
rden<=1'b1;
rdaddress<=address;
@(posedge clock)
rden<=1'b0;
@(posedge clock);
end
endtask

task lectura_escritura( input [4:0] address, input [7:0] valor);
begin
rden<=1'b0;
wren<=1'b0;
@(posedge clock) 
wren<=1'b1;
rden<=1'b1;
wraddress<=address;
rdaddress<=address;
data_in<=valor;
@(posedge clock)
wren<=1'b0;
rden<=1'b0;
@(posedge clock);
end
endtask




                                                
endmodule

