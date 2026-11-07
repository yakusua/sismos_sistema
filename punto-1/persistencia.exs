Code.require_file("structs.exs")
Code.require_file("csv.exs")

defmodule Persistencia do
  @ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @movimientos Path.join(__DIR__, "resources/movimientos.txt")
  @ciudad "id@nombre@habitantes\n"
  @movimiento "codigo@id_ciudad@hora_inicio@hora_final@magnitud@profundidad\n"


  def guardar_ciudad(ciudad, parser) do
    contenido = Csv.generar_mensaje_csv(ciudad, parser) <> "\n"

    if File.exists?(@ciudades) do
      Csv.anexar(@ciudades, contenido)
    else
      Csv.crear_con_cabecera(@ciudades, @ciudad, contenido)
    end

  end

  def guardar_movimiento(movimiento, parser) do
    contenido = Csv.generar_mensaje_csv(movimiento, parser) <> "\n"

    if File.exists?(@movimientos) do
      Csv.anexar(@movimientos, contenido)
    else
      Csv.crear_con_cabecera(@movimientos, @movimiento, contenido)
    end

  end

  def cargar_ciudades(parser) do
    Csv.leer_csv(@ciudades, parser)
  end

  def cargar_movimientos(parser) do
    Csv.leer_csv(@movimientos, parser)
  end

end
