module ApplicationHelper
  DATETIME_FORMAT = '%Y-%m-%d %H:%M'.freeze

  def format_datetime(datetime)
    datetime&.strftime(DATETIME_FORMAT)
  end
end
