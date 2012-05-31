module ForksHelper
  def form_pre_filled?
    Rails.env.development?
  end
end
