// =====================================================================
// FIFO_Coverage: cobertura funcional de la FIFO
//   - Recibe transacciones (FIFO_Transaction) por un mailbox
//   - Cada vez que llega una, la mide con el covergroup
// =====================================================================
class FIFO_Coverage #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 32
);

  // ------------------------------------------------------------------
  // 2. Handle de transaccion
  //    NO lo construimos: apuntara a la transaccion que llegue por el mailbox
  // ------------------------------------------------------------------
  FIFO_Transaction #(WIDTH,DEPTH) tr;

  // ------------------------------------------------------------------
  // 3. Mailbox que solo acepta transacciones FIFO_Transaction
  // ------------------------------------------------------------------
  mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx;

  // ------------------------------------------------------------------
  // 4. Covergroup SIN trigger (no lleva @posedge)
  //    Solo mide cuando nosotros llamamos a fifo_cover.sample(tr)
  // ------------------------------------------------------------------
  covergroup fifo_cover with function sample(FIFO_Transaction #(WIDTH,DEPTH) tr);

    // ---- 4.1 Cuantas palabras hay en la FIFO ----
    grado_llenado: coverpoint tr.use_dw
    {
      bins intermedio[]      = {[1:31]};   // un bin para cada valor de 1 a 31
      bins corner_case_vacio = {0};        // FIFO vacia
      bins corner_case_lleno = {32};       // FIFO llena
    }

    // ---- 4.2 Flags de vacia y llena ----
    // OJO: empty y full son activos en BAJO (vienen de F_EMPTY_N y F_FULL_N)
    //      el primer bit es empty y el segundo es full
    flags: coverpoint {tr.empty, tr.full}
    {
      bins flag_vacio      = {2'b01};      // empty=0 -> vacia
      bins flag_lleno      = {2'b10};      // full=0  -> llena
      bins flag_intermedio = {2'b11};      // ninguna activa -> a medias
      illegal_bins flags_no_posibles = {2'b00};   // vacia y llena a la vez: imposible
    }

    // ---- 4.3 Operacion que se hace en el ciclo ----
    //      el primer bit es la lectura y el segundo la escritura
    rw: coverpoint {tr.read_enable, tr.write_enable}
    {
      bins solo_lectura      = {2'b10};
      bins solo_escritura    = {2'b01};
      bins lectura_escritura = {2'b11};
      bins nada              = default;    // el resto (2'b00)
    }

    // ---- 4.4 Cruce: cada grado de llenado con cada operacion ----
    estados_normales: cross grado_llenado, rw;

    // ---- 4.5 Cruce: cada operacion con cada flag ----
    casos_especiales: cross rw, flags
    {
      bins casos_intermedios = binsof(flags.flag_intermedio);

      // Casos que nunca deben pasar, asi que no los contamos:
      ignore_bins escribir_llena = binsof(flags.flag_lleno) && binsof(rw.solo_escritura);
      ignore_bins leer_vacia     = binsof(flags.flag_vacio) && binsof(rw.solo_lectura);
    }

  endgroup

  // ------------------------------------------------------------------
  // 5. Constructor
  // ------------------------------------------------------------------
  function new(mailbox #(FIFO_Transaction #(WIDTH,DEPTH)) mbx);
    this.mbx   = mbx;      // guardamos el mailbox que nos pasan
    fifo_cover = new();    // construimos el covergroup (obligatorio en una clase)
  endfunction

  // ------------------------------------------------------------------
  // 6. Bucle infinito: esperar una transaccion y medirla
  // ------------------------------------------------------------------
  task cobertura();
    forever begin
      mbx.get(tr);             // espera (bloqueado) hasta que llegue una transaccion
      fifo_cover.sample(tr);   // la medimos con el covergroup
    end
  endtask

endclass
