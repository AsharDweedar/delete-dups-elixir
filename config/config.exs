use Mix.Config

config :delete_dups,
	mongo_config: [
		name: :data_base,
		pool: DBConnection.Poolboy,
		port: 5000,
		database: System.get_env("DATA_BASE") ,
		auth_source: "admin"
	]

config :mnesia, dir: 'mnesia/#{Mix.env}/#{node()}'

