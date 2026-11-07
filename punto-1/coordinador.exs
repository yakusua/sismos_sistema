defmodule Coordinador do
  def leer_archivos(ruta_ciudades, ruta_movimientos) do
    coordinador = self()

    spawn(fn ->
      send(
        coordinador,
        {:resultado_archivo, :ciudades, Archivos.leer_ciudades(ruta_ciudades)}
      )
    end)

    spawn(fn ->
      send(
        coordinador,
        {:resultado_archivo, :movimientos, Archivos.leer_movimientos(ruta_movimientos)}
      )
    end)

    %{}
    |> recibir_respuestas()
    |> evaluar()
  end

  defp recibir_respuestas(respuestas) when map_size(respuestas) == 2, do: respuestas

  defp recibir_respuestas(respuestas) do
    receive do
      {:resultado_archivo, archivo, resultado}
      when archivo in [:ciudades, :movimientos] ->
        recibir_respuestas(Map.put(respuestas, archivo, resultado))
    end
  end

  defp evaluar(%{
         ciudades: {:ok, ciudades, rechazadas_ciudades},
         movimientos: {:ok, movimientos, rechazados_movimientos}
       }) do
    {:ok, ciudades, rechazadas_ciudades, movimientos, rechazados_movimientos}
  end

  defp evaluar(respuestas) do
    errores =
      Enum.flat_map([:ciudades, :movimientos], fn archivo ->
        case Map.fetch!(respuestas, archivo) do
          {:error, razon} -> [{archivo, razon}]
          _ -> []
        end
      end)

    {:error, errores}
  end
end
