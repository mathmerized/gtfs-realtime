module GtfsRealtime
  class InitializeGenerator < Rails::Generators::Base
    argument :config_name, type: :string
    source_root File.expand_path('../templates', __FILE__)

    def create_jobs
      (config_name == 'all' ? GTFS::Realtime::Configuration.all : GTFS::Realtime::Configuration.where(name: config_name)).each do |config|


        create_file "app/jobs/#{config.name.gsub(' ', '').underscore}_job.rb", <<-FILE
class #{config.name.gsub(' ', '').classify}Job
  def perform
    GTFS::Realtime.refresh_realtime_feed!(GTFS::Realtime::Configuration.find_by(name: '#{config.name}'), false)
  end
end
        FILE
      end
    end

    def setup_cronotab
      if config_name == 'all'
        create_file 'config/cronotab.rb', <<-RUBY
require 'gtfs-realtime-new.pb.rb'
        RUBY
      end

      (config_name == 'all' ? GTFS::Realtime::Configuration.all : GTFS::Realtime::Configuration.where(name: config_name)).each do |config|
        append_to_file 'config/cronotab.rb', <<-RUBY
Crono.perform(#{config.name.gsub(' ', '').classify}Job).every #{config.interval_seconds}.seconds
        RUBY
      end
    end
  end
end