// =====================================================================
// FIFO_Monitor: observa la FIFO a traves del interfaz (modport monitor)
//   - Para la COBERTURA: cada flanco captura todas las señales y las manda
//   - Para el SCOREBOARD: en los ciclos significativos manda las entradas,
//     y un ciclo despues las salidas que ha dado la FIFO
// "has a": el monitor TIENE una cobertura y un scoreboard
// =====================================================================
class FIFO_Monitor #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32
);

  // ==================================================================
  // PARTE DE COBERTURA (sesion anterior, sin cambios)
  // ==================================================================

  // Transaccion donde capturamos las señales (esta SI se construye)
  FIFO_Transaction #(WIDTH,DEPTH) tr;

  // Transaccion clonada que mandamos a la cobertura
  FIFO_Transaction #(WIDTH,DEPTH) tr_clon;

  // Mailbox hacia la cobertura
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx;

  // Interfaz virtual con el modport monitor (clocking px)
  virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif;

  // Cobertura funcional
  FIFO_Coverage #(WIDTH,DEPTH) cov;

  // ==================================================================
  // PARTE DE SCOREBOARD (nuevo)
  // ==================================================================

  // 1. Dos mailbox hacia el scoreboard
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_sb_in;    // entradas significativas
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx_sb_out;   // salidas obtenidas (1 ciclo despues)

  // 2. Dos handles para clonar la transaccion base
  FIFO_Transaction #(WIDTH,DEPTH) tr_in;    // la que va al predictor
  FIFO_Transaction #(WIDTH,DEPTH) tr_out;   // la que se rellenara con las salidas

  // 3. Scoreboard
  FIFO_Scoreboard #(WIDTH,DEPTH) sb;

  // ------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------
  function new(virtual fifo_if #(.WIDTH(WIDTH), .DEPTH(DEPTH)).monitor fifo_vif);
    this.fifo_vif = fifo_vif;   // guardamos el interfaz que nos pasan

    // Cobertura
    mbx = new();                // mailbox hacia la cobertura
    tr  = new();                // transaccion base
    cov = new(mbx);             // cobertura con EL MISMO mailbox

    // 4. Scoreboard
    mbx_sb_in  = new();                     // mailbox de entradas
    mbx_sb_out = new();                     // mailbox de salidas
    sb = new(mbx_sb_in, mbx_sb_out);        // scoreboard con LOS MISMOS mailbox
  endfunction

  // ------------------------------------------------------------------
  // Bucle para la COBERTURA (sin cambios): capturar, clonar y enviar
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

  // ------------------------------------------------------------------
  // 5. Bucle para el SCOREBOARD
  // ------------------------------------------------------------------
  task monitorizar_scoreboard();
    forever begin
      // Esperamos un flanco de subida del clocking px
      @(fifo_vif.px);

      // Dos clones de la transaccion base: dos objetos NUEVOS e independientes
      tr_in  = tr.clone();
      tr_out = tr.clone();

      // Rellenamos tr_in con lo que hay ahora en el interfaz.
      // (Lo leemos aqui directamente del interfaz y no de "tr", porque el
      //  bucle de la cobertura actualiza "tr" en este mismo flanco y no
      //  sabemos cual de los dos bucles se ejecuta antes.)
      tr_in.rst_a        = fifo_vif.px.rst_a;
      tr_in.rst_s        = fifo_vif.px.rst_s;
      tr_in.data_in      = fifo_vif.px.data_in;
      tr_in.write_enable = fifo_vif.px.wr_en;
      tr_in.read_enable  = fifo_vif.px.rd_en;
      tr_in.data_out     = fifo_vif.px.data_out;   // salida actual: si no hay lectura,
      tr_in.full         = fifo_vif.px.lleno;      // el predictor la deja igual
      tr_in.empty        = fifo_vif.px.vacio;
      tr_in.use_dw       = fifo_vif.px.use_dw;

      // Solo los ciclos SIGNIFICATIVOS: lectura, escritura o clear sincrono
      if (tr_in.read_enable || tr_in.write_enable || !tr_in.rst_s) begin

        // A y B en paralelo. join_any: en cuanto termine uno (A, que es
        // inmediato) seguimos con el bucle, y B sigue trabajando por su cuenta.
        // Asi el bucle avanza UN ciclo por vuelta y no se pierde ningun flanco.
        fork
          // Copia local del handle de salida: en la siguiente vuelta tr_out
          // apuntara a otro objeto, pero B tiene que rellenar ESTE
          automatic FIFO_Transaction #(WIDTH,DEPTH) salida = tr_out;

          // A: mandamos las entradas al predictor
          mbx_sb_in.put(tr_in);

          // B: esperamos un ciclo (latencia de la FIFO) y mandamos las salidas
          begin
            @(fifo_vif.px);
            salida.data_out = fifo_vif.px.data_out;
            salida.full     = fifo_vif.px.lleno;
            salida.empty    = fifo_vif.px.vacio;
            salida.use_dw   = fifo_vif.px.use_dw;
            mbx_sb_out.put(salida);
          end
        join_any

      end
    end
  endtask

endclass
