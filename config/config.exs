use Mix.Config

config :delete_dups,
	mongo_config: [
		name: :data_base,
		pool: DBConnection.Poolboy,
		port: 5000,
		database: "delete_dups",
		auth_source: "admin"
	]
