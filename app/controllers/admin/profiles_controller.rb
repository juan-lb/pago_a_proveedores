class Admin::ProfilesController < Admin::MainController

  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  def index
    @profiles = Profile.all
  end

  def show; end

  def new
    @profile = Profile.new
  end

  def edit; end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      create_permissions

      flash[:success] = 'Perfil añadido exitosamente.'
      redirect_to [:admin, :profiles]
    else
      flash[:error] = "Error al añadir perfil: #{@profile.errors.full_messages.to_sentence}"
      redirect_to [:new, :admin, :profile]
    end
  end

  def update
    @profile.update(profile_params)
    create_permissions

    redirect_to [:admin, :profiles], success: t(:updated)
  end

  def destroy
    @profile.destroy

    redirect_to [:admin, :profiles], success: t(:deleted)
  end

  def change_profile_operator_category
    if @current_profile.national?
      @current_profile.update(operator_category: 'international')
    else
      @current_profile.update(operator_category: 'national')
    end

    flash[:success] = 'Cambio realizado exitosamente.'
    redirect_to root_path
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:email, :role, :operator_category, :aptour_initials, :report_message, :email_from)
  end

  def create_permissions
    @profile.permissions.delete_all

    return true unless params[:permissions].present? &&
      params[:permissions].any?

    @profile.permissions.create(
      params[:permissions].map { |permission| {key: permission} }
    )
  end

end
