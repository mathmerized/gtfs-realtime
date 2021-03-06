require "gtfs"
require "active_record"
require "bulk_insert"
require "partitioned"
require "gtfs/gtfs_gem_patch"

require 'carrierwave'
require 'fog-aws'

require 'chronic'

require 'gtfs/realtime/engine'

require "gtfs/realtime/version"

module GTFS
  class Realtime
    # This is a singleton object, so everything will be on the class level
    class << self

      attr_accessor :test

      # this method is run to add feeds
      def configure(new_configurations=[])
        run_migrations

        new_configurations.each do |config|
          GTFS::Realtime::Configuration.create!(config) unless GTFS::Realtime::Configuration.find_by(name: config[:name])
        end
      end

      #
      # This method queries the feed URL to get the latest GTFS-RT data and saves it to the database
      # It can be run manually or on a schedule
      #
      # @param [String] config_name name of feed saved in the configuration
      #
      def refresh_realtime_feed!(config, reload_transit_realtime=true)

        if config.handler.present?
          klass = config.handler.constantize
        else
          klass = GTFS::Realtime::RealtimeFeedHandler
        end

        handler = klass.new(gtfs_realtime_configuration: config)
        handler.process
      end

      def run_migrations
        ActiveRecord::Migrator.migrate(File.expand_path("../realtime/migrations", __FILE__))
      end
    end
  end
end
