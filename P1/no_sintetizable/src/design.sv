module FIFO_no_sintetizable
#(parameter DEPTH=32, parameter WIDTH=8)

//pasamelo a formato no ansi c
(CLOCK, RESET_N, CLEAR_N, DATA_IN, READ, WRITE, DATA_OUT, USE_DW, F_EMPTY_N, F_FULL_N);
	  // FIFO interface signals
    input 	logic CLOCK;//!reloj de sistema
    input  logic RESET_N; //!reset asíncrono activo en bajo
    input  logic CLEAR_N; //!limpia la fifo, activo en bajo
    input  logic [WIDTH-1:0] DATA_IN; //!dato a escribir en la fifo
    input  logic READ; //!señal de lectura
    input  logic WRITE; //!señal de escritura
    output logic [WIDTH-1:0] DATA_OUT; //!dato leido de la fifo
    output logic [$clog2(DEPTH):0] USE_DW; //!número de palabras usadas en la fifo
    output logic F_EMPTY_N; //!fifo vacía activo a nivel bajo
    output logic F_FULL_N; //!fifo llena activo a nivel bajo
  

  
  
  logic [WIDTH-1:0] cola [$:DEPTH] ;


  
always_ff @(negedge RESET_N, posedge CLOCK)
if (!RESET_N)
begin
  cola.delete(); 
  DATA_OUT<='0;
end
else
if (!CLEAR_N)
begin
  cola.delete();
  DATA_OUT<='0;
end
else
  begin
    case ({READ,WRITE})
      2'b01: if (cola.size()<DEPTH) cola.push_front(DATA_IN);
      2'b10: DATA_OUT<=cola.pop_back(); 
      2'b11: begin 

              cola.push_front(DATA_IN);              
              DATA_OUT<=cola.pop_back(); 
            end

    endcase

  end

  assign  USE_DW=cola.size();
  assign  F_FULL_N=!(cola.size()==DEPTH);
  assign  F_EMPTY_N=!(cola.size()==0); 
     

property  llenado ;
    (@(posedge CLOCK) not (WRITE==1'b1 && F_FULL_N==1'b0 &&READ==1'b0));
endproperty
sobrellenado:assert property (llenado)  else $error("estas escribiendo sobre una fifo llena");

property  vaciado ;
  (@(posedge CLOCK) not (READ==1'b1 && F_EMPTY_N==1'b0&& WRITE==1'b0)) ;
endproperty
sobrevaciado:assert property  (vaciado) else $error("estas leyendo de una fifo vacia");
  

endmodule
