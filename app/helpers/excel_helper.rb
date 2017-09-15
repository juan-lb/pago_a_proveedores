module ExcelHelper

  def create_excel(s)
    @head = s.add_style sz: 18, b: true, alignment: {horizontal: :center, vertical: :center, wrap_text: true}
    @table_head = s.add_style alignment: {horizontal: :center, vertical: :center, wrap_text: true}, bg_color: "00", fg_color: "FF", border: Axlsx::STYLE_THIN_BORDER
    @table = s.add_style alignment: {wrap_text: false}, border: Axlsx::STYLE_THIN_BORDER
    @bold = s.add_style b: true
    @centered_head = s.add_style alignment: {horizontal: :center, vertical: :center, wrap_text: true}, b: true
    @centered_table = s.add_style alignment: {horizontal: :center, vertical: :center, wrap_text: true}, border: Axlsx::STYLE_THIN_BORDER
    @currency_table_cell = s.add_style alignment: {horizontal: :center, vertical: :center, wrap_text: true}, border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00;-#,##0.00"
    @currency_bold_table_cell = s.add_style alignment: {horizontal: :center, vertical: :center, wrap_text: true}, border: Axlsx::STYLE_THIN_BORDER, format_code: "#,##0.00;-#,##0.00", b: true
  end

  def excel_header(sheet, txt, width=5)
    sheet.add_row [txt], :style => @head
    4.times { sheet.add_row [] }
    col = ('A'.ord + width - 1).chr
    sheet.merge_cells("A1:#{col}5")
  end

  def excel_table_head(sheet, head_row)
    sheet.add_row head_row, style: @table_head
  end

  def excel_table_body(sheet, values)
    excel_table_body_with_style(sheet, values, Axlsx::STYLE_THIN_BORDER)
  end

  def excel_table_body_with_style(sheet, values, style)
    values.each do |value|
      sheet.add_row value, style: style
    end
  end

  def excel_empty_rows(sheet, size)
    size.times { sheet.add_row [] }
  end

end
