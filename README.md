# Parcial II — Programación 3

Observatorio Sismológico de la Universidad del Quindío (Elixir, sin Mix).

## Punto 1 — Reporte local

- **Carpeta desde la que se ejecuta:** `punto-1/`
- **Comando:**

```
elixir main.exs
```

- **Archivos de entrada:** `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`
- **Reporte generado:** `punto-1/resources/reporte_sismos.txt` (también se muestra en consola)

## Punto 2 — Consulta entre nodos

Se necesitan dos terminales. Primero se inicia el servidor y después el cliente.
Ambos nodos deben usar la misma cookie (`parcial`), que se configura con la opción `--cookie`.

| Nodo     | Nombre                  | Cookie    |
|----------|-------------------------|-----------|
| Servidor | `servidor@127.0.0.1`    | `parcial` |
| Cliente  | `cliente@127.0.0.1`     | `parcial` |

**Terminal 1 — Servidor** (carpeta: `punto-2/nodo-servidor/`)

```
elixir --name servidor@127.0.0.1 --cookie parcial servidor.exs
```

- Archivos de entrada: `punto-2/nodo-servidor/resources/ciudades.txt` y `punto-2/nodo-servidor/resources/movimientos.txt`

**Terminal 2 — Cliente** (carpeta: `punto-2/nodo-cliente/`)

```
elixir --name cliente@127.0.0.1 --cookie parcial cliente.exs
```

## Verificación del punto 2

Identificadores usados en el cliente:

| Consulta                              | Identificador |
|---------------------------------------|---------------|
| Ciudad con movimientos registrados    | `C01`         |
| Ciudad sin movimientos registrados    | `C03`         |
| Ciudad inexistente                    | `C99`         |

El cliente muestra las respuestas en este orden: reporte de `C01`, reporte de `C03`, «La ciudad no está registrada» (`C99`) y reporte general; termina al recibir `:fin`.

Para comprobar que el servidor sigue atendiendo solicitudes, se deja el servidor activo en la Terminal 1 y se ejecuta de nuevo el mismo comando del cliente en la Terminal 2 (carpeta `punto-2/nodo-cliente/`):

```
elixir --name cliente@127.0.0.1 --cookie parcial cliente.exs
```
