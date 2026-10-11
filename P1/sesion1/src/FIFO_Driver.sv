// DRIVER (controlabilidad): genera los estimulos de la FIFO a traves del interfaz.
// "has a": el driver TIENE un RCSG_subir y un RCSG_bajar.
class FIFO_Driver #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 16
);

// Handles de los generadores aleatorios
  utilidades_pkg::RCSG_subir #(WIDTH, DEPTH) gen_subir;
  utilidades_pkg::RCSG_bajar #(WIDTH, DEPTH) gen_bajar;

// Interfaz virtual con el modport driver (clocking tx y neg_event)
  virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver fifo_vif;

//1 constructor: recibe el interfaz y construye los generadores
  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).driver fifo_vif);
    this.fifo_vif  = fifo_vif;           // this.fifo_vif = el del driver ; fifo_vif = el argumento
    gen_subir = new();
    gen_bajar = new();
  endfunction

//2 reset asincrono (con el clocking neg_event, en flancos de bajada)
  task reset_asincrono();
    // entradas sincronas en reposo
    fifo_vif.tx.wr_en   <= 1'b0;
    fifo_vif.tx.rd_en   <= 1'b0;
    fifo_vif.tx.rst_s   <= 1'b1;    // clear inactivo
    fifo_vif.tx.data_in <= '0;

    @(fifo_vif.neg_event);
    fifo_vif.neg_event.rst_a <= 1'b1;   // 1er flanco de bajada: reset inactivo
    @(fifo_vif.neg_event);
    fifo_vif.neg_event.rst_a <= 1'b0;   // 2o flanco de bajada: reset activo
    repeat (3) @(fifo_vif.neg_event);
    fifo_vif.neg_event.rst_a <= 1'b1;   // 3 flancos despues: reset inactivo

    RCSG_base #(WIDTH, DEPTH)::reset_llenado();   // la FIFO esta vacia -> llenado = 0

    @(fifo_vif.tx);                     // esperamos un flanco de subida para sincronizar
  endtask

//3 metodo con MAS escrituras que lecturas (usa RCSG_subir)
  task subir(int n_ciclos);
    repeat (n_ciclos) begin
      if (!gen_subir.randomize())
        $error("Fallo al aleatorizar RCSG_subir");
      fifo_vif.tx.data_in <= gen_subir.data;
      fifo_vif.tx.wr_en   <= gen_subir.wr_rd[1];   // bit alto = escritura
      fifo_vif.tx.rd_en   <= gen_subir.wr_rd[0];   // bit bajo = lectura
      fifo_vif.tx.rst_s   <= gen_subir.clear;
      @(fifo_vif.tx);                              // un estimulo por ciclo
    end
    reposo();
  endtask

//4 metodo con MAS lecturas que escrituras (usa RCSG_bajar)
  task bajar(int n_ciclos);
    repeat (n_ciclos) begin
      if (!gen_bajar.randomize())
        $error("Fallo al aleatorizar RCSG_bajar");
      fifo_vif.tx.data_in <= gen_bajar.data;
      fifo_vif.tx.wr_en   <= gen_bajar.wr_rd[1];
      fifo_vif.tx.rd_en   <= gen_bajar.wr_rd[0];
      fifo_vif.tx.rst_s   <= gen_bajar.clear;
      @(fifo_vif.tx);
    end
    reposo();
  endtask

//5 dejar la FIFO sin leer ni escribir (si no, se quedaria repitiendo el ultimo estimulo)
  task reposo();
    fifo_vif.tx.wr_en <= 1'b0;
    fifo_vif.tx.rd_en <= 1'b0;
    @(fifo_vif.tx);
  endtask

endclass