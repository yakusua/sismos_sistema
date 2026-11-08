defmodule Coordinador do
  @moduledoc """
  este modulo esta encargado de gestionar los procesos de gestion de archivos con respecto a las ciudades y movimientos,
  gestionandolos simultaneamente, para que se ejecuten a la vez, resiviendo la respuesta y formateandola a conveniencia
  """

  @doc """
  este proceso lanza los dos trabajadores, que a su vez pasa su idp, para que se le entregen los resultados, ademas usa evaluar para reformatear el resultado
  """
  def leer_archivos(ruta_ciudades, ruta_movimientos) do
    coordinador = self()

    spawn(fn -> trabajador_ciudades(coordinador, ruta_ciudades) end)
    spawn(fn -> trabajador_movimientos(coordinador, ruta_movimientos) end)

    recibir_respuestas(%{})
    |> evaluar()
  end

  @doc """
  manda el resultado de ejecutar leer ciudades de archivo, a coordinador
  """
  defp trabajador_ciudades(coordinador, ruta) do
    send(coordinador, {:resultado_archivo, :ciudades, Archivos.leer_ciudades(ruta)})
  end

  @doc """
  manda a coordinador, el resultado de leer movimientos, de archivo
  """
  defp trabajador_movimientos(coordinador, ruta) do
    send(coordinador, {:resultado_archivo, :movimientos, Archivos.leer_movimientos(ruta)})
  end

  @doc """
  cuando se resivieron dos respuestas, se entrega el resultado para continuar el flujo
  """
  defp recibir_respuestas(respuestas) when map_size(respuestas) == 2, do: respuestas

  @doc """
  este se usa para esperar a que las dos funciones se ejecuten, y no se evalue solo una respuesta
  """
  defp recibir_respuestas(respuestas) do
    receive do
      {:resultado_archivo, archivo, resultado} ->
        recibir_respuestas(Map.put(respuestas, archivo, resultado))
    end
  end

  @doc """
  toma los resultados y los refactoriza
  """
  defp evaluar(%{ciudades: {:ok, ciudades, rech_c}, movimientos: {:ok, movimientos, rech_m}}) do
    {:ok, ciudades, rech_c, movimientos, rech_m}
  end

  @doc """
  cuando algo salio mal, en alguno de los dos trabajadores, osea el archivo no existe o es de un tipo incompatible etc.
  """
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
