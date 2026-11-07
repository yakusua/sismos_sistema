defmodule Reporte do
  # ---------- Cálculo ----------

  # Un solo recorrido recursivo: cantidad, movimiento de mayor magnitud y suma de profundidades.
  def estadisticas(movimientos) do
    recorrer(movimientos, 0, nil, 0.0)
  end

  defp recorrer([], cantidad, mayor, suma), do: {cantidad, mayor, suma}

  defp recorrer([movimiento | resto], cantidad, nil, suma) do
    recorrer(resto, cantidad + 1, movimiento, suma + movimiento.profundidad)
  end

  defp recorrer([movimiento | resto], cantidad, mayor, suma) do
    nuevo_mayor = if movimiento.magnitud > mayor.magnitud, do: movimiento, else: mayor
    recorrer(resto, cantidad + 1, nuevo_mayor, suma + movimiento.profundidad)
  end

  # ---------- Reportes ----------

  def generar_general(ciudades, rechazados_ciudades, movimientos, rechazados_movimientos) do
    {validos, sin_ciudad} = separar_por_catalogo(movimientos, ciudades)

    bloques =
      Enum.map(ciudades, fn ciudad ->
        bloque_ciudad(ciudad, movimientos_de(ciudad.id, validos))
      end)

    rechazados = [
      "Registros rechazados",
      "ciudades.txt: #{rechazados_ciudades}",
      "movimientos.txt: #{rechazados_movimientos + length(sin_ciudad)}"
    ]

    (["REPORTE DE SISMOS POR CIUDAD"] ++ bloques ++ [Enum.join(rechazados, "\n")])
    |> Enum.join("\n\n")
  end

  def generar_ciudad(id_ciudad, ciudades, movimientos) do
    case Enum.find(ciudades, fn ciudad -> ciudad.id == id_ciudad end) do
      nil -> "La ciudad no está registrada"
      ciudad -> bloque_ciudad(ciudad, movimientos_de(ciudad.id, movimientos))
    end
  end

  # ---------- Formato ----------

  defp separar_por_catalogo(movimientos, ciudades) do
    Enum.split_with(movimientos, fn movimiento ->
      Enum.any?(ciudades, fn ciudad -> ciudad.id == movimiento.id_ciudad end)
    end)
  end

  defp movimientos_de(id_ciudad, movimientos) do
    Enum.filter(movimientos, fn movimiento -> movimiento.id_ciudad == id_ciudad end)
  end

  defp bloque_ciudad(ciudad, movimientos) do
    {cantidad, mayor, suma} = estadisticas(movimientos)

    [
      "Ciudad: #{ciudad.nombre}",
      "Habitantes: #{ciudad.habitantes}",
      detalle(movimientos),
      "Total de movimientos: #{cantidad}",
      "Movimiento de mayor magnitud: #{texto_mayor(mayor)}",
      "Profundidad promedio: #{texto_promedio(cantidad, suma)}"
    ]
    |> Enum.join("\n")
  end

  defp detalle([]), do: "Sin movimientos registrados"

  defp detalle(movimientos) do
    lineas =
      Enum.map(movimientos, fn m ->
        "  #{m.codigo} | Inicio: #{Time.to_string(m.hora_inicio)} | Final: #{Time.to_string(m.hora_final)}" <>
          " | Magnitud: #{m.magnitud} | Profundidad: #{m.profundidad} km"
      end)

    Enum.join(["Movimientos:" | lineas], "\n")
  end

  defp texto_mayor(nil), do: "No aplica"
  defp texto_mayor(movimiento), do: "#{movimiento.codigo} · #{movimiento.magnitud}"

  defp texto_promedio(0, _suma), do: "No aplica"

  defp texto_promedio(cantidad, suma) do
    :erlang.float_to_binary(suma / cantidad, decimals: 2) <> " km"
  end
end
