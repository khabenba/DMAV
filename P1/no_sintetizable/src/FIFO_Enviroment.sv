// ENVIRONMENT: contiene el driver (controlabilidad) y el monitor (observabilidad).
// "has a": el environment TIENE un driver y un monitor.
class FIFO_Enviroment #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);

  FIFO_Driver  #(WIDTH, DEPTH) driver;
  FIFO_Monitor #(WIDTH, DEPTH) monitor;

  // Dos argumentos: el interfaz con modport driver y el interfaz con modport monitor
  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver  fifo_vif_driver,
               virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif_monitor);
    driver  = new(fifo_vif_driver);    // al driver le pasamos el de modport driver
    monitor = new(fifo_vif_monitor);   // al monitor le pasamos el de modport monitor
  endfunction

endclass
