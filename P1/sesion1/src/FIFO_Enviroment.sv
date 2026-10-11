// ENVIRONMENT: de momento solo contiene el driver.
// "has a": el environment TIENE un driver.
class FIFO_Enviroment #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);

  utilidades_pkg::FIFO_Driver #(WIDTH, DEPTH) driver;

  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver fifo_vif);
    driver = new(fifo_vif);         // le pasamos el interfaz hacia abajo
  endfunction

endclass
