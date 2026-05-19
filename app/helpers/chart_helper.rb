module ChartHelper
  include ActionView::Helpers::NumberHelper

  DONUT_PALETTE = %w[#059669 #f59e0b #ef4444 #6366f1 #14b8a6 #f97316 #8b5cf6 #0ea5e9].freeze

  def chart_currency(value, precision: 2)
    number_to_currency(value, unit: "R$ ", separator: ",", delimiter: ".", precision: precision)
  end

  # Mini gráfico de linha (sparkline) sem eixos. Aceita Array<Numeric>.
  def sparkline(values, width: 120, height: 32, stroke: "#059669", fill: "#10b98122")
    values = Array(values).map(&:to_f)
    return tag.span(class: "text-xs text-gray-400") { "—" } if values.length < 2

    min = values.min
    max = values.max
    range = (max - min).zero? ? 1.0 : (max - min)
    step = values.length > 1 ? width.to_f / (values.length - 1) : width.to_f

    points = values.each_with_index.map do |v, i|
      x = (i * step).round(2)
      y = (height - ((v - min) / range) * height).round(2)
      [x, y]
    end

    path_line = "M " + points.map { |x, y| "#{x},#{y}" }.join(" L ")
    path_area = path_line + " L #{width},#{height} L 0,#{height} Z"

    content_tag(:svg,
      class: "block",
      viewBox: "0 0 #{width} #{height}",
      preserveAspectRatio: "none",
      width: width,
      height: height,
      role: "img",
      aria: { hidden: true }) do
      safe_join([
        tag.path(d: path_area, fill: fill, stroke: "none"),
        tag.path(d: path_line, fill: "none", stroke: stroke, "stroke-width" => 2, "stroke-linecap" => "round", "stroke-linejoin" => "round")
      ])
    end
  end

  # Barras agrupadas (receitas/despesas) + linha de saldo.
  # data: Array de Hashes { label:, receitas:, despesas:, saldo: }
  def grouped_bar_chart(data, height: 240)
    return empty_chart_message("Sem dados financeiros para exibir") if data.blank?

    valores = data.flat_map { |d| [d[:receitas].to_f, d[:despesas].to_f, d[:saldo].to_f] }
    if valores.all? { |v| v.to_f.zero? }
      return empty_chart_message("Sem movimentações no período selecionado")
    end

    max_val = valores.map(&:abs).max
    max_val = 1.0 if max_val.zero?

    rotate_labels = data.length > 8

    width = 720
    padding_left = 56
    padding_right = 24
    padding_top = 16
    padding_bottom = rotate_labels ? 56 : 36
    inner_w = width - padding_left - padding_right
    inner_h = height - padding_top - padding_bottom

    group_w = inner_w.to_f / data.length
    bar_w = [group_w * 0.34, 32].min
    bar_w = 3.0 if bar_w < 3
    gap = [group_w * 0.08, 2.0].max

    grid_lines = build_grid_lines(max_val, padding_left, padding_top, inner_w, inner_h)
    bars = []
    labels = []
    saldo_points = []

    data.each_with_index do |d, i|
      gx = padding_left + group_w * i + group_w / 2.0

      label_y = padding_top + inner_h + (rotate_labels ? 14 : 22)
      labels << if rotate_labels
                  tag.text(d[:label],
                    x: gx, y: label_y,
                    "text-anchor" => "end",
                    transform: "rotate(-40 #{gx.round(2)} #{label_y})",
                    class: "fill-gray-500 text-[10px]")
                else
                  tag.text(d[:label],
                    x: gx, y: label_y,
                    "text-anchor" => "middle",
                    class: "fill-gray-500 text-[10px]")
                end

      [
        { val: d[:receitas].to_f, color: "#10b981", offset: -1, name: "Receitas" },
        { val: d[:despesas].to_f, color: "#ef4444", offset: 1,  name: "Despesas" }
      ].each do |b|
        h = (b[:val] / max_val) * inner_h
        x = gx + b[:offset] * (bar_w / 2.0 + gap / 2.0) - bar_w / 2.0
        y = padding_top + inner_h - h
        bars << content_tag(:g) do
          safe_join([
            tag.rect(x: x.round(2), y: y.round(2),
              width: bar_w.round(2), height: [h.round(2), 0].max,
              rx: 3, ry: 3, fill: b[:color], opacity: 0.92),
            tag.title("#{b[:name]} #{d[:label]}: #{chart_currency(b[:val])}")
          ])
        end
      end

      saldo_ratio = d[:saldo].to_f / max_val
      saldo_ratio = saldo_ratio.clamp(0.0, 1.0)
      saldo_y = padding_top + inner_h - saldo_ratio * inner_h
      saldo_points << [gx, saldo_y, d[:saldo].to_f]
    end

    saldo_path = "M " + saldo_points.map { |x, y, _| "#{x.round(2)},#{y.round(2)}" }.join(" L ")

    content_tag(:svg,
      viewBox: "0 0 #{width} #{height}",
      preserveAspectRatio: "xMidYMid meet",
      class: "w-full h-auto",
      role: "img",
      aria: { label: "Gráfico de receitas, despesas e saldo" }) do
      safe_join([
        grid_lines,
        *bars,
        tag.path(d: saldo_path, fill: "none", stroke: "#0f766e", "stroke-width" => 2, "stroke-dasharray" => "4 4", "stroke-linecap" => "round"),
        *saldo_points.map { |x, y, v| tag.circle(cx: x.round(2), cy: y.round(2), r: 3.5, fill: v >= 0 ? "#0f766e" : "#dc2626", stroke: "#fff", "stroke-width" => 1.5) },
        *labels
      ])
    end
  end

  # Donut chart com legenda. data: Hash { "Label" => valor }
  def donut_chart(data, size: 200, thickness: 28, palette: DONUT_PALETTE)
    data = data.to_h.reject { |_, v| v.to_f <= 0 }
    return empty_chart_message("Sem dados para exibir") if data.empty?

    total = data.values.sum.to_f
    cx = size / 2.0
    cy = size / 2.0
    radius = (size / 2.0) - thickness / 2.0 - 2

    paths = []
    angle = -Math::PI / 2

    data.each_with_index do |(_, value), i|
      sweep = (value / total) * 2 * Math::PI
      x1 = cx + radius * Math.cos(angle)
      y1 = cy + radius * Math.sin(angle)
      x2 = cx + radius * Math.cos(angle + sweep)
      y2 = cy + radius * Math.sin(angle + sweep)
      large_arc = sweep > Math::PI ? 1 : 0

      paths << if data.length == 1
                 tag.circle(cx: cx, cy: cy, r: radius, fill: "none",
                   stroke: palette[i % palette.length], "stroke-width" => thickness)
               else
                 tag.path(
                   d: "M #{x1.round(2)} #{y1.round(2)} A #{radius.round(2)} #{radius.round(2)} 0 #{large_arc} 1 #{x2.round(2)} #{y2.round(2)}",
                   fill: "none",
                   stroke: palette[i % palette.length],
                   "stroke-width" => thickness,
                   "stroke-linecap" => "butt"
                 )
               end

      angle += sweep
    end

    svg = content_tag(:svg,
      viewBox: "0 0 #{size} #{size}",
      class: "block",
      width: size, height: size,
      role: "img",
      aria: { hidden: true }) do
      safe_join([
        tag.circle(cx: cx, cy: cy, r: radius, fill: "none", stroke: "#f3f4f6", "stroke-width" => thickness),
        *paths,
        tag.text(chart_currency(total, precision: 0),
          x: cx, y: cy + 4,
          "text-anchor" => "middle",
          class: "fill-gray-900 text-sm font-semibold")
      ])
    end

    legend = content_tag(:ul, class: "w-full space-y-2.5 text-sm") do
      safe_join(data.each_with_index.map do |(label, value), i|
        pct = total.zero? ? 0 : (value / total) * 100
        tag.li(class: "flex items-start gap-2.5") do
          safe_join([
            tag.span("", class: "mt-1.5 inline-block h-2.5 w-2.5 shrink-0 rounded-full", style: "background:#{palette[i % palette.length]}"),
            tag.div(class: "min-w-0 flex-1") do
              safe_join([
                tag.p(label, class: "text-sm font-medium text-gray-800 break-words leading-snug"),
                tag.p(class: "mt-0.5 flex items-baseline gap-2 text-xs text-gray-500 tabular-nums") do
                  safe_join([
                    tag.span(chart_currency(value), class: "font-semibold text-gray-700"),
                    tag.span("· #{pct.round(0)}%", class: "text-gray-500")
                  ])
                end
              ])
            end
          ])
        end
      end)
    end

    content_tag(:div, class: "flex flex-col items-center gap-6 lg:flex-row lg:items-center lg:gap-6") do
      safe_join([
        content_tag(:div, svg, class: "shrink-0"),
        content_tag(:div, legend, class: "w-full min-w-0")
      ])
    end
  end

  def empty_chart_message(text)
    content_tag(:div, text, class: "flex h-40 items-center justify-center rounded-xl bg-gray-50 px-6 text-center text-sm text-gray-500")
  end

  # Pequeno badge de variação percentual (↑ verde, ↓ vermelho)
  def variation_badge(pct, invert: false)
    return tag.span("—", class: "text-xs font-medium text-gray-400") if pct.nil?

    is_up = pct >= 0
    positive = invert ? !is_up : is_up
    color = positive ? "text-emerald-700 bg-emerald-50" : "text-red-700 bg-red-50"
    arrow = is_up ? "↑" : "↓"
    label = "#{arrow} #{pct.abs.round(1)}%"
    tag.span(label, class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold tabular-nums #{color}")
  end

  private

  def build_grid_lines(max_val, padding_left, padding_top, inner_w, inner_h)
    steps = 4
    safe_join((0..steps).map do |i|
      val = max_val * (steps - i) / steps.to_f
      y = padding_top + (inner_h * i / steps.to_f)
      safe_join([
        tag.line(x1: padding_left, y1: y, x2: padding_left + inner_w, y2: y,
          stroke: "#e5e7eb", "stroke-width" => 1, "stroke-dasharray" => (i.zero? || i == steps) ? nil : "3 4"),
        tag.text(chart_currency(val, precision: 0),
          x: padding_left - 8, y: y + 4,
          "text-anchor" => "end",
          class: "fill-gray-400 text-[10px] tabular-nums")
      ])
    end)
  end
end
