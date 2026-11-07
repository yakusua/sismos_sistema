defmodule Archivos do
  def leer_ciudades(ruta) do
    Persistencia.cargar_ciudades(ruta, &Ciudad.ciudad_parser/1)
  end

  def leer_movimientos(ruta) do
    Persistencia.cargar_movimientos(ruta, &Movimiento.movimiento_parser/1)
  end

  def mensaje_errores(errores) do
    errores
    |> Enum.map(fn {archivo, razon} ->
      "Error al leer #{nombre_archivo(archivo)}: #{:file.format_error(razon)}"
    end)
    |> Enum.join("\n")
  end

  defp nombre_archivo(:ciudades), do: "ciudades.txt"
  defp nombre_archivo(:movimientos), do: "movimientos.txt"
end
