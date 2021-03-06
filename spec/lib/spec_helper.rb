require 'coveralls'
Coveralls.wear!

require 'active_record'
require 'data_mapper'

require 'sql_partitioner'

require 'logger'

#require 'ruby-debug' # enable debugger support

SPEC_LOGGER = Logger.new(nil)

RSpec.configure do |config|
  # enable both should and expect syntax in rspec without deprecation warnings
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before :suite do
    require 'yaml'
    db_conf = YAML.load_file('spec/db_conf.yml')

    # establish both ActiveRecord and DataMapper connections
    ActiveRecord::Base.establish_connection(db_conf["test"])

    adapter,database,user,pass,host = db_conf["test"].values_at *%W(adapter database username password host)
    connection_string = "#{adapter}://#{user}:#{pass}@#{host}/#{database}"
    DataMapper.setup(:default, connection_string)
  end

  config.before :each do
    sql = <<-SQL
      DROP TABLE IF EXISTS `test_events`
    SQL
    DataMapper.repository.adapter.execute(sql)

    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS `test_events` (
        `id` bigint(20) NOT NULL AUTO_INCREMENT,
        `timestamp` bigint(20) unsigned NOT NULL DEFAULT '0',
        PRIMARY KEY (`id`,`timestamp`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    SQL
    DataMapper.repository.adapter.execute(sql)

  end
end
