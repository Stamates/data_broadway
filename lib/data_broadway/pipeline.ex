defmodule DataBroadway.Pipeline do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: Pipeline,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: "my_queue",
           connection: [
             username: Application.get_env(:data_broadway, :queue_user),
             password: Application.get_env(:data_broadway, :queue_password)
           ],
           qos: [
             prefetch_count: 50
           ]},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 50
        ]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 1500,
          concurrency: 5
        ]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    Message.update_data(message, fn data -> {data, do_work(data)} end)
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    messages |> Enum.map(& &1.data) |> IO.inspect(label: "Got batch")
    messages
  end

  defp do_work(data), do: String.to_integer(data) * 2
end
