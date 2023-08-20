require "thor/shell/color"
@shell = Thor::Shell::Color.new

ENV.fetch("SEED_USERS") { "" }.split(";").each do |s|
  m = s.match(/(?<username>.+):(?<password>.+)<(?<email>.+@.+)>/)
  username = m["username"]&.strip
  email = m["email"]&.strip
  password = m["password"]&.strip
  user = User.find_by(email: email)
  if user
    @shell.say_status :exist, "User #{user.username}<#{user.email}>", :cyan
  else
    User.create(username: username, email: email, password: password)
    @shell.say_status :create, "User #{username}<#{email}>", :green
  end
end
