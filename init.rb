require_relative 'file_storage'
FileStorage::Config["scheme_file"] = Dir.pwd + '/db/scheme/scheme.rb'
FileStorage::Config["db_folder"] = Dir.pwd + '/db/data'
FileStorage::Config["db_records_folder"] = FileStorage::Config["db_folder"] + '/records'
FileStorage::Config["db_table_states_folder"] = FileStorage::Config["db_folder"] + '/last_ids'
FileStorage::Config["models_folder"] = "./models" unless FileStorage::Config["models_folder"]

Dir.glob("#{FileStorage::Config["models_folder"]}/**/*.rb") do |file|
  model = /\.\/models\/(.+?\/)*([^\/]+)\.rb/.match(file)
  autoload model.to_a.last.camelize.to_sym, file
end

require_relative 'spec/irb_test'
