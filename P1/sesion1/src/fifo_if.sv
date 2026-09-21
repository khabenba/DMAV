`timescale 1 ns/ 1 ps
//incluid vuestro código


//cabecera del interfaz. Recorda con dos parámetros y un puerto de entrada
interface #(WIDTH=8, DEPTH=32) fifo_if (input bit clk);
 
  localparam ADDRESS=$clog2(DEPTH);  
 
  logic       rst_a      ;
  logic       rst_s      ;
  logic       lleno    ;
  logic       vacio    ;
  logic       rd_en    ; 
  logic       wr_en    ;
  logic   [ADDRESS:0]     use_dw ;
  logic   [WIDTH-1:0]     data_in;
  logic   [WIDTH-1:0]     data_out;
 
//4.2 definición clocking tx
clocking tx @(posedge clk);
 
  output #2ns     rst_s;
  output #2ns     data_in;
  output #2ns       rd_en; 
  output #2ns       wr_en;  
endclocking:tx;
 
 
//4.3 definición del clocking neg_event
clocking neg_event @(negedge clk);
output #2ns rst_a;
endclocking:neg_event;
 
//5.3 definición del modport driver
//os proporciono el código
modport driver (clocking tx,
  clocking neg_event   
);
 
//5.1 definición del modport duv
//añadir vuestro código, absolutamente necesario para esta primera sesion
modport duv (
  input             clk      ,
  input             rst_a    ,
  input             rst_s    ,
  input             rd_en    , 
  input             wr_en    ,
  input             data_in  ,
  output            lleno    ,
  output            use_dw   ,
  output            data_out ,
);
 
//4.1 definición clocking px
//añadir vuestro código, solo necesario para la segunda sesion
 
//5.2 definición del modport monitor
//añadir vuestro código, solo necesario para la segunda sesion
 
endinterface