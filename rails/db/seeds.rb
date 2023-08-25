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

specs = open(Rails.root.join("db/specs.yaml"), &YAML.method(:load_file))
specs.each do |key, attrs|
  spec = Spec.find_by(key: key)
  if spec
    @shell.say_status :exist, "Spec #{spec.name} (#{spec.key})", :cyan
  else
    spec = Spec.create(key: key, name: attrs[:label], body: attrs)
    @shell.say_status :create, "Spec #{spec.name} (#{spec.key})", :green
  end
end
