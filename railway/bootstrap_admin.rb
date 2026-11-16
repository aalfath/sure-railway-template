# Creates the instance's first user (super admin) from ADMIN_EMAIL and
# ADMIN_PASSWORD. Runs on every boot but does nothing once any user exists,
# so a password changed in the app is never overwritten.
email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
password = ENV["ADMIN_PASSWORD"].to_s

if User.exists?
  puts "[sure-railway] users already exist; skipping admin bootstrap"
elsif email.empty? || password.length < 8
  puts "[sure-railway] ADMIN_EMAIL empty or ADMIN_PASSWORD shorter than 8 characters; skipping admin bootstrap"
else
  ActiveRecord::Base.transaction do
    User.lock_first_user_role!
    user = User.new(
      email: email,
      password: password,
      password_confirmation: password,
      family: Family.new,
      role: User.role_for_new_family_creator
    )
    user.save!
    puts "[sure-railway] created first admin #{email} (role #{user.role})"
  end
end
