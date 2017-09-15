class ProviderImportation

  def call
    Provider.delete_all

    providers = ApiProvider.all.map do |external_provider|
      Provider.new(
        aptour_id: external_provider.id_prestador,
        name:      external_provider.nom_pre
      )
    end

    Provider.import providers
  end

end
