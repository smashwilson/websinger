# Source: http://calicowebdev.com/2011/01/25/rails-3-sqlite-3-in-memory-databases/
# Load the current schema into the in-memory database when running unit tests.

def in_memory_database?
  Rails.env == 'test' and
    ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter || 
    ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter and
    Rails.configuration.database_configuration['test']['database'] == ':memory:'
end

if in_memory_database?
  puts "creating sqlite in memory database"
  load "#{Rails.root}/db/schema.rb"
end

