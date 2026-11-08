defmodule Cliente do
  @moduledoc """
  este modulo, maneja la relacion con servidor, osea lanza solicitudes y resive respuestas
  """
  @nodo_servidor :"servidor@127.0.0.1"

  @doc """
  inicia el proceso, conecta con el nodo del servidor, si se conecta, realiza solicitudes y resive respuestas
  """
  def iniciar do
    Process.register(self(), :servicio_respuesta)

    case Node.connect(@nodo_servidor) do
      true ->
        enviar_solicitudes()
        recibir_respuestas()

      _ ->
        IO.puts("Error: no se pudo conectar al nodo servidor #{@nodo_servidor}")
    end
  end

  @doc """
  realiza solicitudes de prueba, al nodo servicio.
  """
  defp enviar_solicitudes do
    destino_respuesta = {:servicio_respuesta, node()}

    [
      {:reporte_ciudad, "C01"},
      {:reporte_ciudad, "C03"},
      {:reporte_ciudad, "C99"},
      :reporte_general,
      :fin
    ]
    |> Enum.each(fn solicitud ->
      send({:servicio_sismos, @nodo_servidor}, {destino_respuesta, solicitud})
    end)
  end

  @doc """
  esta funcion, se encarga de imprimir todas las respuestas, hasta que servicio, le devuelva la solicitud para terminar.
  """
  defp recibir_respuestas do
    receive do
      :fin ->
        :ok

      respuesta ->
        IO.puts(respuesta)
        recibir_respuestas()
    end
  end
end

Cliente.iniciar()
