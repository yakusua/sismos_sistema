defmodule Cliente do
  @nodo_servidor :"servidor@127.0.0.1"

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
