module 

RAM_DP #(parameter mem_depth=32, parameter size=8)
(
input [size-1:0] data_in,
input wren,clock,rden,
input [$clog2(mem_depth-1)-1:0] wraddress, 
input [$clog2(mem_depth-1)-1:0] rdaddress,
output logic [size-1:0] data_out
);

logic [size-1:0] mem [mem_depth-1 :0];

always @(posedge clock)
  begin
  if (wren==1'b1)
        mem[wraddress]<=data_in;
  data_out<=mem[rdaddress];   
  end

  
  
escritura_lectura_misma_direccion: assert property (@(posedge clock)  (wren&&wraddress==rdaddress)|->NO_BYPASS);

operacion_lectura:assert property (@(posedge clock)  !$stable(rdaddress)&&!wren|->lectura);

operacion_escritura:assert property (@(posedge clock)  wren|->escritura);
sequence escritura;
 logic [7:0] dataux;
 logic [4:0] addaux;
  (1, dataux=data_in, addaux=wraddress) ##1 (mem[addaux]===dataux) ;
endsequence
sequence lectura;
 logic [7:0] aux;
  (1, aux=mem[rdaddress]) ##1 (data_out===aux) ;
endsequence
sequence NO_BYPASS;
 logic [7:0] aux, aux2;
  (1, aux=data_in, aux2=mem[rdaddress]) ##1 (data_out===aux2) ##1 (data_out===aux) ;
endsequence

endmodule 