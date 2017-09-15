module ImportationChecker
  extend ActiveSupport::Concern

  included do
    before_action :check_if_importation_is_running
  end

private

  def check_if_importation_is_running
    if Setting.is_importation_running?
      redirect_to importation_running_imports_path
    end
  end

end
