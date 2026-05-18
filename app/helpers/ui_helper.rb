module UiHelper
  UI_ICONS = {
    dashboard: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6",
    clientes: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
    estoque: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4",
    financeiro: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
    manutencao: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z",
    mesa: "M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z",
    plus: "M12 6v6m0 0v6m0-6h6m-6 0H6"
  }.freeze

  def ui_page_shell
    content_for :body_class, "bg-white"
    content_for :page_layout, "mx-auto max-w-7xl px-4 pb-10 pt-6 sm:px-6 lg:px-8"
  end

  def ui_page_header(breadcrumbs:, title:, subtitle:, icon: :dashboard)
    content_for :page_header do
      render partial: "shared/page_header",
             locals: { breadcrumbs: breadcrumbs, title: title, subtitle: subtitle, icon_path: UI_ICONS.fetch(icon) }
    end
  end

  def ui_input_class
    "w-full rounded-xl border border-gray-200 px-4 py-3 text-gray-900 placeholder:text-gray-400 focus:border-emerald-600 focus:outline-none focus:ring-2 focus:ring-emerald-600/20"
  end

  def ui_select_class
    "#{ui_input_class} bg-white"
  end

  def ui_label_class
    "mb-2 block text-sm font-medium text-gray-700"
  end

  # Cabeçalhos de tabela — mesmo verde da navbar (bg-emerald-800)
  def ui_table_th_class(align: :left, compact: false, dense: false)
    align_class = align == :right ? "text-right" : "text-left"
    size = if compact
      "px-4 py-2.5 tracking-wide"
    elsif dense
      "px-6 py-3 tracking-wider"
    else
      "px-6 py-4 tracking-wider"
    end
    "#{size} #{align_class} text-xs font-semibold uppercase text-emerald-800"
  end

  def ui_badge_count(text)
    render partial: "shared/badge", locals: { text: text }
  end

  def ui_btn_primary_class
    "inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-emerald-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600 focus-visible:ring-offset-2"
  end

  def ui_toolbar_layout_class
    "flex w-full flex-col gap-3 sm:flex-row sm:items-stretch"
  end

  def ui_toolbar_form_class
    "flex w-full min-w-0 flex-1 flex-col gap-3 sm:flex-row sm:items-center sm:gap-3"
  end

  def ui_toolbar_actions_class
    "flex w-full shrink-0 flex-wrap items-center gap-2 border-t border-gray-100 pt-3 sm:w-auto sm:border-t-0 sm:border-l sm:border-gray-200 sm:pl-4 sm:pt-0"
  end

  def ui_toolbar_search_wrapper_class
    "relative w-full min-w-0 flex-1"
  end

  def ui_filter_select_class
    "#{ui_select_class} w-full min-w-0 sm:flex-1"
  end

  def ui_phone_field_options(extra_data: {})
    {
      inputmode: "tel",
      placeholder: "(00) 00000-0000",
      data: { mask_phone: true }.merge(extra_data)
    }
  end

  def ui_fichas_field_options(extra_data: {})
    {
      inputmode: "numeric",
      maxlength: 6,
      placeholder: "12345",
      data: { input_digits: true, digits_min: 5, digits_max: 6 }.merge(extra_data)
    }
  end

  def ui_digits_field_options(max:, min: nil, extra_data: {})
    data = { input_digits: true, digits_max: max }
    data[:digits_min] = min if min
    {
      inputmode: "numeric",
      maxlength: max,
      data: data.merge(extra_data)
    }
  end

  def ui_decimal_field_options(max_int: 10, scale: 2, extra_data: {})
    {
      inputmode: "decimal",
      maxlength: max_int + 1 + scale,
      data: { input_decimal: true, decimal_max_int: max_int, decimal_scale: scale }.merge(extra_data)
    }
  end

  def ui_metric_value_class(value, color_class: "text-gray-900")
    length = value.to_s.gsub(/\s/, "").length
    size = case length
    when 0..11 then "text-3xl"
    when 12..15 then "text-2xl"
    when 16..19 then "text-xl"
    else "text-lg"
    end

    "mt-2 min-w-0 font-bold tabular-nums leading-tight break-words #{size} #{color_class}"
  end

  def ui_metric_currency(value, color_class: "text-gray-900")
    formatted = format_currency(value)
    tag.p(formatted, class: ui_metric_value_class(formatted, color_class: color_class), title: formatted)
  end

  def ui_metric_currency_span(value, color_class: "text-gray-900")
    formatted = format_currency(value)
    classes = ui_metric_value_class(formatted, color_class: color_class).sub("mt-2 ", "min-w-0 shrink text-right ")
    tag.span(formatted, class: classes, title: formatted)
  end

  def ui_status_badge(label, variant: :neutral)
    classes = case variant
    when :critical
      "inline-flex items-center gap-1.5 rounded-full border-2 border-red-400 bg-red-100 px-3 py-1 text-xs font-bold uppercase tracking-wide text-red-900 shadow-sm"
    when :success
      "inline-flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-100 px-2.5 py-1 text-xs font-semibold text-emerald-800"
    when :warning
      "inline-flex items-center gap-1.5 rounded-full border-2 border-amber-400 bg-amber-100 px-3 py-1 text-xs font-bold uppercase tracking-wide text-amber-900 shadow-sm"
    else
      "inline-flex items-center rounded-full bg-gray-100 px-2.5 py-1 text-xs font-medium text-gray-700"
    end

    icon = if variant.in?(%i[critical warning])
      tag.svg(class: "h-3.5 w-3.5 shrink-0", fill: "currentColor", viewBox: "0 0 20 20", aria: { hidden: true }) do
        tag.path(fill_rule: "evenodd", d: "M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 6a.75.75 0 00-.75.75v3.5a.75.75 0 001.5 0v-3.5A.75.75 0 0010 6zm0 8a1 1 0 100-2 1 1 0 000 2z", clip_rule: "evenodd")
      end
    end

    tag.span(class: classes) { safe_join([ icon, label ].compact) }
  end

  def ui_manutencao_status_variant(status)
    case status
    when "pendente" then :warning
    when "cancelada" then :critical
    when "concluida" then :success
    else :neutral
    end
  end

  def ui_filter_submit
    submit_tag "Filtrar", class: "inline-flex shrink-0 items-center rounded-xl border border-gray-200 bg-white px-5 py-3 text-sm font-medium text-gray-700 shadow-sm transition hover:bg-gray-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600"
  end

  def ui_icon_path(name)
    UI_ICONS.fetch(name.to_sym)
  end

  def ui_icon_svg(name, css_class: "h-4 w-4")
    tag.svg(
      class: css_class,
      fill: "none",
      stroke: "currentColor",
      viewBox: "0 0 24 24",
      aria: { hidden: true }
    ) do
      tag.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        stroke_width: 2,
        d: ui_icon_path(name)
      )
    end
  end

  def ui_nav_items
    [
      ["Dashboard", root_path, "dashboard", :dashboard],
      ["Clientes", clientes_path, "clientes", :clientes],
      ["Estoque", estoque_index_path, "estoque", :estoque],
      ["Financeiro", financeiro_index_path, "financeiro", :financeiro],
      ["Manutenção", manutencao_index_path, "manutencao", :manutencao]
    ]
  end

  def ui_nav_link_class(active:)
    base = "inline-flex items-center gap-2 rounded-lg font-medium transition"
    if active
      "#{base} bg-emerald-600 text-white"
    else
      "#{base} text-white/90 hover:bg-white/10"
    end
  end

  def ui_filter_clear(path)
    link_to "Limpar", path, class: "inline-flex shrink-0 items-center rounded-xl px-5 py-3 text-sm font-medium text-emerald-700 hover:text-emerald-900"
  end

  def ui_field_class(record, attribute, base: nil)
    classes = base || ui_input_class
    record.errors.include?(attribute) ? "#{classes} border-red-400 focus:border-red-500 focus:ring-red-500/20" : classes
  end

  def ui_row_attrs(path, label: "Abrir detalhes", extra_class: nil)
    {
      class: [ "cursor-pointer transition-colors hover:bg-emerald-50/40 focus-within:bg-emerald-50/40", extra_class ].compact.join(" "),
      data: { row_href: path },
      tabindex: 0,
      role: "link",
      aria: { label: label }
    }
  end

  def ui_search_input_class
    "#{ui_input_class} pl-11"
  end

  def ui_filters_active_chip
    content_tag(:span, "Filtros ativos", class: "inline-flex items-center gap-1.5 rounded-full border border-emerald-300 bg-emerald-100 px-2.5 py-0.5 text-xs font-semibold text-emerald-800")
  end

  def ui_modal_data
    { turbo_frame: ModalFormResponses::MODAL_FRAME }
  end

  def ui_modal_icon_path(variant)
    case variant.to_sym
    when :show
      "M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"
    when :create
      "M12 6v6m0 0v6m0-6h6m-6 0H6"
    else
      "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
    end
  end

  def ui_modal_link(*args, **options, &block)
    options[:data] = ui_modal_data.merge(options[:data] || {})
    if block
      link_to(args.first, options, &block)
    else
      link_to(*args, **options)
    end
  end
end
