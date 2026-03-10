module ApplicationHelper
  def nav_item(text, path, icon_path)
    active = current_page?(path) ? "bg-green-500 text-white shadow-lg" : "text-green-100 hover:bg-green-600 hover:text-white"
    content_tag(:a, href: path, class: "flex items-center space-x-3 px-4 py-3 rounded-lg transition #{active}") do
      content_tag(:svg, content_tag(:path, "", d: icon_path, "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2"), class: "w-5 h-5 flex-shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") +
      content_tag(:span, text, class: "font-medium")
    end
  end

  def format_currency(value)
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def format_date(date)
    date.strftime("%d/%m/%Y") if date
  end
end

