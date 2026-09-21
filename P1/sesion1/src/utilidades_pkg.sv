//insertar código que define una escala de tiempos de 1 ns y una precisón de 1 ps.
`timescale 1 ns/ 1 ps

//directiva de escala
package utilidades_pkg;
 
 
typedef class RCSG_base;
typedef class RCSG_subir;
typedef class RCSG_bajar;
// typedef class Scoreboard;
// typedef class FIFO_Transaction;
typedef class FIFO_Enviroment;
typedef class FIFO_Driver;
// typedef class FIFO_Coverage;
// typedef class FIFO_Monitor;
typedef class FIFO_Testaleatorio1;
 
`include "RCSG_base.sv"
`include "RCSG_subir.sv"
`include "RCSG_bajar.sv"
//`include "FIFO_Scoreboard.sv"
//'include "FIFO_Transaction.sv"
`include "FIFO_Enviroment.sv"
`include "FIFO_Driver.sv"
//`include "FIFO_Coverage.sv"
// `include "FIFO_Monitor.sv"
`include "FIFO_Testaleatorio1.sv"
 
 
endpackage : utilidades_pkg