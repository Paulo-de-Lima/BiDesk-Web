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

  def ui_badge_count(text)
    render partial: "shared/badge", locals: { text: text }
  end

  def ui_btn_primary_class
    "inline-flex items-center gap-2 rounded-xl bg-emerald-700 px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-emerald-800 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600 focus-visible:ring-offset-2"
  end

  def ui_filter_submit
    submit_tag "Filtrar", class: "inline-flex shrink-0 items-center rounded-xl border border-gray-200 bg-white px-5 py-3 text-sm font-medium text-gray-700 shadow-sm transition hover:bg-gray-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-emerald-600"
  end

  def ui_icon_path(name)
    UI_ICONS.fetch(name)
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
