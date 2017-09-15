class OperatorImportation

  def call
    Operator.delete_all

    operators = ApiOperator.not_aerials.map do |external_operator|
      Operator.new(
        aptour_id:           external_operator['id_ope'],
        name:                external_operator['nom_ope'].strip,
        category:            get_category(external_operator),
        has_current_account: (external_operator['id_cat'] != 1),
        has_ig_retention:    external_operator['ret_ganan'],
        detail:              external_operator['detalle'].strip,
        address:             external_operator['dom_ope'],
        cuit:                external_operator['num_iva'],
        business_name:       external_operator['razon'],
        bank_accounts:       process_accounts(external_operator['bank_accounts'])
      )
    end

    Operator.import operators
  end


  private

  def get_category(external_operator)
    case external_operator['id_cat2']
    when 1
      'national'
    when 2
      'international'
    else
      'undefined'
    end
  end

  def process_accounts(accounts)
    accounts.map do |each|
      {
        bank:     each['banco'].strip,
        type:     each['tipo_cuenta'],
        currency: each['moneda'],
        number:   each['numero'].strip,
        cbu:      each['cbu'].strip,
        holder:   each['titular'].strip,
        cuit:     each['cuit'].strip
      }
    end
  end

end

# DETALLE DE LO QUE VIENE DE APTOUR
# id_cat: tiene cuenta corriente -> tiene cuenta corriente (0), no tiene (1)
# id_cat2: categoría -> nacional(1), internacional(2)
# ret_ganan: es sujeto de retención
# detalle: a veces viene la información bancaria
