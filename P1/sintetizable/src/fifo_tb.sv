`timescale 1 ns/ 1 ps
import utilidades_pkg::*; // Import the utilities package
module fifo_tb();

//definición de parámetros superiores
parameter DATA_WIDTH = 8;
parameter DEPTH=32;

//definicon de señales e interconexion
logic clk;
logic rst_a;
logic rst_s;

//2. instanciación del interfaz (va antes que el DUV porque el DUV lo usa)
fifo_if #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) bus (clk);

//1.instanciación del top del diseño
FIFO_top_duv #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) duv (.bus(bus));

//3. Generación del reloj con un initial
initial begin
  clk = 1'b0;
  forever #10 clk = !clk;
end

//4. Almacenamiento de puertos en un vcd
initial begin
  $dumpfile("fifo_tb_all.vcd");
  $dumpvars(1,fifo_tb.duv.fifo_duv);
end

//5. Lanzamiento del test dentro de un initial con un paso previo e definición del handle al test del paso 6
FIFO_Testaleatorio1 #(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) test;

initial begin
  test = new(bus, bus);            // le pasamos el interfaz; el modport ya va en el constructor
  test.prueba_aleatoria();
  $stop;
end

endmodule
