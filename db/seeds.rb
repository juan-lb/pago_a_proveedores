profiles = ['admin@snappler.com', 'carlos@aerolaplata.com.ar']

profiles.each do |email|
  profile = Profile.find_by(email: email)

  if profile.present?
    profile.update(role: 'admin')
  else
    Profile.create(email: email, role: 'admin')
  end

end

Setting.create(
  ig_limit:   2000,
  ig_aliquot: 2,
  ig_base:    20
) if Setting.count == 0
