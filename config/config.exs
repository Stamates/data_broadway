use Mix.Config

# Configures the endpoint
config :data_broadway,
  queue_user: System.get_env("RABBITMQ_USER"),
  queue_password: System.get_env("RABBITMQ_PWD")
