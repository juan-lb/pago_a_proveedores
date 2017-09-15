class OperatorsPresenter

  def initialize(params: nil)
    @params = params
  end

  def filter
    @filter ||= OperatorsFilter.new(filter_params)
  end

  def operators
    @operators ||= filter.call.
      paginate(page: @params[:page], per_page: Const::PER_PAGE)
  end

  private

  def filter_params
    if @params[:operators_filter]
      @params.require(:operators_filter).permit(:name, :category)
    end
  end

end
