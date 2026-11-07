Code.require_file("csv.exs", __DIR__)

defmodule Persistencia do
  @ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @movimientos Path.join(__DIR__, "resources/movimientos.txt")
  @cabecera_ciudades "id@nombre@habitantes"
  @cabecera_movimientos "codigo@id_ciudad@hora_inicio@hora_final@magnitud@profundidad"

  # Al guardar se serializan estructuras; los parsers se reservan para la lectura.
  def guardar_ciudad(ciudad) do
    contenido =
      Csv.generar_mensaje_csv(ciudad, fn ciudad ->
        "#{ciudad.id}@#{ciudad.nombre}@#{ciudad.habitantes}"
      end) <> "\n"

    guardar(@ciudades, @cabecera_ciudades <> "\n", contenido)
  end

  def guardar_movimiento(movimiento) do
    contenido =
      Csv.generar_mensaje_csv(movimiento, fn movimiento ->
        [
          movimiento.codigo,
          movimiento.id_ciudad,
          Time.to_string(movimiento.hora_inicio),
          Time.to_string(movimiento.hora_final),
          movimiento.magnitud,
          movimiento.profundidad
        ]
        |> Enum.join("@")
      end) <> "\n"

    guardar(@movimientos, @cabecera_movimientos <> "\n", contenido)
  end

  def cargar_ciudades(ruta, parser) do
    cargar(ruta, parser)
  end

  def cargar_movimientos(ruta, parser) do
    cargar(ruta, parser)
  end

  def cargar_ciudades(parser), do: cargar_ciudades(@ciudades, parser)
  def cargar_movimientos(parser), do: cargar_movimientos(@movimientos, parser)

  defp cargar(ruta, parser) do
    case File.stat(ruta) do
      {:ok, %{type: :regular}} ->
        # Csv.leer_csv/2 retorna resultados de parser envueltos; se normalizan aquí para el coordinador y el reporte.
        ruta
        |> Csv.leer_csv(parser)
        |> normalizar_resultado()

      {:ok, _} ->
        {:error, :eisdir}

      {:error, razon} ->
        {:error, razon}
    end
  end

  defp normalizar_resultado({{:ok, validos}, {:error_parser, invalidos}}) do
    registros = Enum.map(validos, fn {:ok, registro} -> registro end)
    lineas_rechazadas = Enum.map(invalidos, &linea_rechazada/1)
    {:ok, registros, lineas_rechazadas}
  end

  defp linea_rechazada({:error, linea}), do: linea
  defp linea_rechazada({:error_parser, linea}), do: linea

  defp guardar(ruta, cabecera, contenido) do
    if File.exists?(ruta) do
      Csv.anexar(ruta, contenido)
    else
      Csv.crear_con_cabecera(ruta, cabecera, contenido)
    end
  end
end
