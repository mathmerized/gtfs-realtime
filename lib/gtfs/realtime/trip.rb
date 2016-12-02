module GTFS
  class Realtime
    class Trip < GTFS::Realtime::Model
      many_to_one :route
      one_to_many :stop_times
      many_to_many :stops, join_table: :gtfs_realtime_stop_times
      one_to_many :calendar_dates, primary_key: :service_id, key: :service_id
      one_to_many :shapes, primary_key: :shape_id, key: :id

      def active?(date)
        # can't use .where chaining b/c Sequel is weird
        calendar_dates.find{|cd| cd.exception_type == GTFS::Realtime::CalendarDate::ADDED && cd.date == date}
      end
    end
  end
end
