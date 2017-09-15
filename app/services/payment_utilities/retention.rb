class Retention

  def call(operator:, total:)
    retention(operator, total)
  end

  private

  def retention(operator, total)
    return 0 unless operator.has_ig_retention

    ig_retention = set_ig_retention(operator)
    accumulated  = total + ig_retention.accumulated
    setting      = Setting.first

    if accumulated <= setting.ig_limit
      gross_amount = 0
    else
      if (ig_retention.accumulated > setting.ig_limit)
        gross_amount = total
      else
        gross_amount = (accumulated - setting.ig_limit)
      end
    end

    retention = ((setting.ig_aliquot * gross_amount)/100).round(2)

    if retention < setting.ig_base
      retention = 0
    end

    retention
  end

  def set_ig_retention(operator)
    if operator.has_ig_retention?
      retention = IgRetention.where(operator_aptour_id: operator.aptour_id).first_or_create do |ig_ret|
        ig_ret.accumulated = 0
        ig_ret.month = Time.zone.today.beginning_of_month
      end
      actual_month = Time.zone.today.beginning_of_month
      if retention.month != actual_month
        retention.update(month: actual_month, accumulated: 0)
      end
    end

    retention
  end

end
