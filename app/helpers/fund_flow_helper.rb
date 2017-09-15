module FundFlowHelper

  def build_chart_data(name, values, key)
    [
      name: name,
      data: values.map { |each| [each[:label], each[key]] }
    ]
  end

end
