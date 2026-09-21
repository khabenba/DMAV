// Code`timescale 1 ns/ 1 ps

module FIFO_tb_v0();

parameter DEPTH=32, WIDTH=8;
localparam ADDRESS=$clog2(DEPTH);
 
logic  clock, reset, rden,wren,clear;
logic  [WIDTH-1:0] data_in;
logic  [ADDRESS:0] use_dw;



logic [4:0] rdaddress;

logic [4:0] wraddress;

logic full,empty;                                              
logic [WIDTH-1:0]  data_out;
  



//Modelo de la FIFO

logic [7:0] FIFO_ideal [$]; //Definida con una cola
mailbox FIFO_ideal_mbox = new(); //definida con un mailbox

// Instancia del DUV
FIFO_no_sintetizable DUV (.CLOCK(clock),
               .RESET_N(reset),
               .DATA_IN(data_in),
               .READ(rden),
               .WRITE(wren),
               .CLEAR_N(1'b1),
               .F_FULL_N(full),
               .F_EMPTY_N(empty),
			   .USE_DW(use_dw),
               .DATA_OUT(data_out));





// Casos de Test	  
initial
begin
$info("INICIO VALIDACION");
inicializacion();

$info("*** TEST 1: Escritura simple");
test_A();
$info("*** FIN TEST 1 ****");



$info   ("*** TEST 2: LLenado simple de la FIFO");
resetON();
llenar_simple();
$info("*** FIN TEST 2 ****");

$info("*** TEST 3: Escritura y lectura simultanea con FIFO vacia");
resetON();
lectura_escritura(10,10);
$info("*** FIN TEST 3 ****");

$info("*** TEST 3: Escritura y lectura simultanea con FIFO llena");
resetON();
test_B();
$info("*** FIN TEST 3 ****");

$info("*** TEST 4: Llenado y vaciado de la FIFO");
resetON();
test_C();
$info("*** FIN TEST 4 ****");

$info("*** TEST 5: Escritura y lectura aleatoria con FIFO vacia, llena y a mitad.");
resetON();
test_D();
$info("*** FIN TEST 5 ****");


repeat(5) @(posedge clock);
$info("FIN VALIDACION");

$stop;
end


initial begin
  $dumpfile("FIFO_TB.vcd");
  $dumpvars(0,FIFO_tb_v0.DUV);
end  
        

assign clear = 1'b1;
// Generación de reloj
initial                                                
begin   
 clock = 1'b0;                                               
 forever #10 clock = !clock;                    
end




// Inicialización de las entradas 	
task init_inputs();
begin
  data_in <='0;
  wren <= 1'b0;
  rden <= 1'b0;
end
endtask
// Generación de reset
task resetON();
begin
#10 reset=1'b0;
FIFO_ideal={};
repeat(5) @(posedge clock);
#7 reset=1'b1;
end
endtask

// Escritura de datos en la FIFO. 
// La entrada define el número de datos a escribir   
task solo_escritura(input integer n_escrituras);
begin
logic [7:0] dato;
wren<=1'b0;
@(negedge clock) 
wren<=1'b1;
repeat (n_escrituras) begin
 dato = $random%256;
 data_in = dato;
 FIFO_ideal.push_front(dato);
 @(negedge clock);
end
wren <= 1'b0;
end
endtask
// Lectura de datos de la FIFO, el número de datos a leer
// Monitoriza la salida.
task solo_lectura(input integer n_lecturas);
logic [7:0] dato;
begin
  rden <= 1'b0;
  @(negedge clock);
  rden <= 1'b1;
  repeat (n_lecturas) begin 
    @(negedge clock);
    dato = FIFO_ideal.pop_back();
    assert (dato == data_out) else $error("ERROR el dato leido %h no coincide con el esperado %h", dato, data_out);
  end
  rden <= 1'b0;
end
endtask
// Lectura y escritura de datos simultanea. Se definen cuantos datos a leer y a escribir.
task lectura_escritura( input integer n_lecturas, input integer n_escrituras);
fork
solo_escritura(n_escrituras);
solo_lectura(n_lecturas);
join
endtask



    //Monitor de palabras en la fifo
    // palabras en la fifo
integer palabras;
always @(posedge clock, negedge reset)
if (!reset) palabras=0;
    else if (!clear) palabras=0;
else 
   case({wren,rden})
   2'b01: palabras = palabras-1;
   2'b10: palabras = palabras+1;
   endcase
// Asserciones de control de la FIFO

   always @(negedge clock)
begin
if (reset && clear) begin
   assert ((!empty)?(palabras == 0):(palabras != 0)) else $error("ERROR señal de FIFO vacía activada incorrectamente");
   assert ((!full)? (palabras == 32):(palabras != 32)) else $error("ERROR señal de FIFO llena activada incorrectamente");
   assert (palabras <= 32) else $error("ERROR FIFO con tamaño  incorrecto");
  assert (palabras[5:0] == use_dw) else $error("ERROR USE_DW no funciona como se espera");
end
end


//empiezan los tasks de alto nivel:casos de test


task inicializacion;
begin
$display("Inicializacion de las entradas");
init_inputs;
$display(" reset inicial");
resetON();
end
endtask

// Escritura simple de dos valores y una lectura.
task test_A;
begin
$display(" escribo dos valores");
solo_escritura(1);
solo_escritura(1);
$display("leo un valor");
solo_lectura(1);
end
endtask

// Escritura y lectura simultanea con fifo llena.
task test_B;
begin
llenar_simple;
lectura_escritura(10,10);
end
endtask

// Test de llenado y vaciado.
task test_C;
begin

llenar_simple;
vaciado_simple();
lectura_escritura(10,10);
end
endtask



task test_D;
begin
  vaciado_simple();
  rd_wr_random(100);
  llenar_simple;
  rd_wr_random(100);
  vaciado_simple();
  solo_escritura(15);
  rd_wr_random(100);
end
endtask

 // Escrituras y lecturas aleatorias.
 task rd_wr_random(integer numero);
 begin
   integer caso;   
   repeat(numero) begin
   caso = $random%3;
   case (caso)
    0: if (empty) solo_lectura(1);
    1: if (full) solo_escritura(1);
    2:  lectura_escritura(1,1);
    endcase
   end
 end
 
endtask

// Task de llenado de la FIFO
task llenar_simple();
logic [7:0]cuenta;
begin
 cuenta=8'b0;
  while (full==1'b1)
 begin
  solo_escritura(1);
  cuenta++;
 end
  
end
endtask

// Task de vaciado de la FIFO
task vaciado_simple();
logic [7:0]cuenta;
begin
 cuenta<=8'b0;
 while (empty==1'b1)
 begin
  solo_lectura(1);
  cuenta++;
 end
 
 
end
endtask
endmodule 
// or browse Examples
