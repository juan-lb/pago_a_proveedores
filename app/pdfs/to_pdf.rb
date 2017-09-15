class ToPdf < Prawn::Document

  def initialize(view, page_layout = :portrait)
    super(:page_layout => page_layout)
    @view = view
    font 'Helvetica', size: 10
  end

  def h1(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 30, style: :bold, align: options[:align]
    move_down 10
  end

  def h2(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 25, style: :bold, align: options[:align]
    move_down 10
  end

  def h3(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 20, style: :bold, align: options[:align]
    move_down 10
  end

  def h4(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 16, style: :bold, align: options[:align]
    move_down 10
  end

  def h5(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 14, style: :bold, align: options[:align]
    move_down 10
  end

  def h6(text, *args)
    options = args.extract_options!
    options[:align] ||= :center

    text text, size: 12, style: :bold, align: options[:align]
    move_down 10
  end

  def p(text, *args)
    options = args.extract_options!
    options[:align] ||= :left
    options[:style] ||= :normal
    text text, style: options[:style], align: options[:align]
  end

  def field(label, content)
    text "<b>#{label}: </b> #{content.presence || '--' }", inline_format: true
    move_down 5
  end

  def display_table(data, highlight_last_row=false)
    table(data, cell_style: { borders: [], padding: 0 }, width: 520, header: true) do |table|
      table.row(0).font_style = :bold
      table.row(0..data.count).padding    = 4
      table.row(0).borders    = [:top, :bottom]
      table.row(0).padding    = 4

      if highlight_last_row
        table.row(-1).font_style = :bold
      end
    end
    move_down 10
  end

  def to_currency(a_value)
    @view.number_to_currency(a_value)
  end

  def display_separator
    move_down 10
    stroke_horizontal_rule
    move_down 10
  end

  def logo(url)
    image url, :at => [5,740], :width => 100
  end

end
