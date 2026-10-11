// =====================================================================
// FIFO_Monitor: observa la FIFO a traves del interfaz (modport monitor)
//   - Cada flanco de subida captura todas las señales en una transaccion
//   - Clona la transaccion y la manda por el mailbox a la cobertura
// "has a": el monitor TIENE una cobertura (FIFO_Coverage)
// =====================================================================
class FIFO_Monitor #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32
);

  // ------------------------------------------------------------------
  // 2. Transaccion donde capturamos las señales (esta SI se construye)
  // ------------------------------------------------------------------
  FIFO_Transaction #(WIDTH,DEPTH) tr;

  // ------------------------------------------------------------------
  // 3. Transaccion clonada: es la que mandamos por el mailbox
  //    (no hace falta construirla: la construye la funcion clone())
  // ------------------------------------------------------------------
  FIFO_Transaction #(WIDTH,DEPTH) tr_clon;

  // ------------------------------------------------------------------
  // 4. Mailbox que solo acepta transacciones FIFO_Transaction
  // ------------------------------------------------------------------
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx;

  // ------------------------------------------------------------------
  // 5. Interfaz virtual con el modport monitor (clocking px)
  // ------------------------------------------------------------------
  virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif;

  // ------------------------------------------------------------------
  // 6. Handle de la clase de cobertura funcional
  // ------------------------------------------------------------------
  FIFO_Coverage #(WIDTH,DEPTH) cov;

  // ------------------------------------------------------------------
  // 7. Constructor
  // ------------------------------------------------------------------
  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif);
    this.fifo_vif = fifo_vif;   // guardamos el interfaz que nos pasan
    mbx = new();                // construimos el mailbox
    tr  = new();                // construimos la transaccion original
    cov = new(mbx);             // construimos la cobertura con EL MISMO mailbox
  endfunction

  // ------------------------------------------------------------------
  // 8. Bucle infinito: capturar, clonar y enviar
  // ------------------------------------------------------------------
  task monitorizar();
    forever begin
      // Esperamos un flanco de subida del clocking px
      @(fifo_vif.px);

      // Capturamos todas las señales (valores de 1 ns antes del flanco)
      tr.rst_a        = fifo_vif.px.rst_a;
      tr.rst_s        = fifo_vif.px.rst_s;
      tr.data_in      = fifo_vif.px.data_in;
      tr.data_out     = fifo_vif.px.data_out;
      tr.write_enable = fifo_vif.px.wr_en;
      tr.read_enable  = fifo_vif.px.rd_en;
      tr.full         = fifo_vif.px.lleno;     // tal cual: activo en bajo
      tr.empty        = fifo_vif.px.vacio;     // tal cual: activo en bajo
      tr.use_dw       = fifo_vif.px.use_dw;

      // Clonamos y mandamos el clon por el mailbox
      tr_clon = tr.clone();
      mbx.put(tr_clon);
    end
  endtask

endclass
