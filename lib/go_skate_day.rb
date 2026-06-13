# frozen_string_literal: true

class GoSkateDay
  MONTH = 6
  DAY = 21
  VISIBILITY_START_MONTH = 5
  VISIBILITY_START_DAY = 21

  class << self
    def visible?(date = Time.zone.today)
      date = date.to_date
      return false if date < visibility_start_for(date.year)
      return false if date > event_date_for(date.year)

      true
    end

    def celebration_day?(date = Time.zone.today)
      date.to_date == event_date_for(date.year)
    end

    def days_remaining(date = Time.zone.today)
      date = date.to_date
      (event_date_for(date.year) - date).to_i
    end

    private

    def event_date_for(year)
      Date.new(year, MONTH, DAY)
    end

    def visibility_start_for(year)
      Date.new(year, VISIBILITY_START_MONTH, VISIBILITY_START_DAY)
    end
  end
end
