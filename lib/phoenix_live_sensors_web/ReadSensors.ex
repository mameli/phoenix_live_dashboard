defmodule ReadSensors do
  use GenServer

  def start_link(_args \\ [], _opts \\ []) do
    GenServer.start_link(__MODULE__, %{messages: []}, name: __MODULE__)
  end

  def init(state) do
    consume()
    {:ok, state}
  end

  def consume() do
    IO.puts("Consuming message")

    case AMQP.Connection.open() do
      {:ok, connection} ->
        case AMQP.Channel.open(connection) do
          {:ok, channel} ->
            AMQP.Exchange.declare(channel, "macbook_sensors", :fanout)
            {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
            AMQP.Queue.bind(channel, queue_name, "macbook_sensors")
            AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
            IO.puts(" [*] Waiting for messages")

          {:error, reason} ->
            {:stop, {:channel_open_error, reason}}
        end

      {:error, reason} ->
        {:stop, {:connection_open_error, reason}}
    end
  end

  def handle_info({:basic_deliver, payload, _meta}, state) do
    PhoenixLiveSensorsWeb.Endpoint.broadcast("sensor_topic", "new_message", %{message: payload})
    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _payload}, state) do
    {:noreply, state}
  end
end
