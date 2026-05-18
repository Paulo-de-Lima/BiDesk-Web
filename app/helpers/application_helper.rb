module ApplicationHelper
  include UiHelper

  def format_currency(value)
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def format_date(date)
    date.strftime("%d/%m/%Y") if date
  end
end
