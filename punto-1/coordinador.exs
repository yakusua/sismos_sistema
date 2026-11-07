defmodule Coordinador do
  # Inicia los dos trabajadores antes de esperar las respuestas y
  # acepta las respuestas en cualquier orden.
  def leer_archivos(ruta_ciudades, ruta_movimientos) do
    coordinador = self()

    spawn(fn -> trabajador_ciudades(coordinador, ruta_ciudades) end)
    spawn(fn -> trabajador_movimientos(coordinador, ruta_movimientos) end)

    recibir_respuestas(%{})
    |> evaluar()
  end

  defp trabajador_ciudades(coordinador, ruta) do
    send(coordinador, {:resultado_archivo, :ciudades, Archivos.leer_ciudades(ruta)})
  end

  defp trabajador_movimientos(coordinador, ruta) do
    send(coordinador, {:resultado_archivo, :movimientos, Archivos.leer_movimientos(ruta)})
  end

  defp recibir_respuestas(respuestas) when map_size(respuestas) == 2, do: respuestas

  defp recibir_respuestas(respuestas) do
    receive do
      {:resultado_archivo, archivo, resultado} ->
        recibir_respuestas(Map.put(respuestas, archivo, resultado))
    end
  end

  defp evaluar(%{ciudades: {:ok, ciudades, rech_c}, movimientos: {:ok, movimientos, rech_m}}) do
    {:ok, ciudades, rech_c, movimientos, rech_m}
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
