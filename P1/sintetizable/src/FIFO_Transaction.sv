class FIFO_Transaction #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 32
);
 
  // FIFO interface signals
  logic rst_a;
  logic rst_s;
  logic [WIDTH-1:0] data_in;
  logic [WIDTH-1:0] data_out;
  logic write_enable;
  logic read_enable;
  logic full;
  logic empty;
  logic [$clog2(DEPTH):0] use_dw;
 
  // Constructor
  //no vamos a poner constructor porque no es necesario en este caso
   
//quiero una función de clonado basado en una función previa de copy
 
  function void copy(FIFO_Transaction #(WIDTH,DEPTH) other); 
//1. Escribir vuestro código aquí. Copia de todas las propiedades procedentes de other
    this.rst_a        = other.rst_a;
    this.rst_s        = other.rst_s;
    this.data_in      = other.data_in;
    this.data_out     = other.data_out;
    this.write_enable = other.write_enable;
    this.read_enable  = other.read_enable;
    this.full         = other.full;
    this.empty        = other.empty;
    this.use_dw       = other.use_dw;
  endfunction  
   
  function FIFO_Transaction #(WIDTH,DEPTH)  clone();     
    // 2.1. Creación de una nueva instancia de FIFO_Transaction
    FIFO_Transaction #(WIDTH,DEPTH) cloned_transaction;
    cloned_transaction = new();
    // 2.2. Copia del objeto actual en la nueva instancia
    cloned_transaction.copy(this);
    // 2.3. Retorno del objeto clonado
    return cloned_transaction;
  endfunction  
 
endclass