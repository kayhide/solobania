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

srcs = Rails.root.glob "db/specs/*.yaml"
srcs.each do |src|
  @shell.say_status :load, src.relative_path_from(Rails.root).to_s
  specs = open(src) { |io| YAML.load_file(io, aliases: true) }
  specs.each do |key, attrs|
    if spec = Spec.find_by(key: key)
      if spec.body == attrs.deep_stringify_keys
        @shell.say_status :exist, "Spec #{spec.name} (#{spec.key})", :cyan
      else
        spec.update!(name: attrs['name'], body: attrs)
        @shell.say_status :update, "Spec #{spec.name} (#{spec.key})", :yellow
      end
    else
      spec = Spec.create!(key: key, name: attrs['name'], body: attrs)
      @shell.say_status :create, "Spec #{spec.name} (#{spec.key})", :green
    end
  end
end
