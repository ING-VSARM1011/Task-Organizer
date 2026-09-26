# Run with: bundle exec rails runner -e test script/smoke_test.rb
abort "Run this check in the test environment" unless Rails.env.test?

# Never read or modify the application's persistent databases.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false
load Rails.root.join("db/schema.rb")

user = User.create!(email: "dependency-check@example.test", password: "DependencyCheck123!")
raise "Password verification failed" unless user.valid_password?("DependencyCheck123!")
raise "Invalid password accepted" if user.valid_password?("incorrect")
category = Category.create!(name: "Dependency check", description: "Smoke test")
task = Task.new(name: "Dependency check", description: "Smoke test",
                due_date: Date.tomorrow, category: category, owner: user)
task.participading_users.build(user: user)
task.save!
raise "Task persistence failed" unless task.reload.participants.include?(user)

session = ActionDispatch::Integration::Session.new(Rails.application)
session.get("/users/sign_in")
raise "Sign-in page failed: #{session.response.status}" unless session.response.status == 200
session.post("/users/sign_in", params: { user: { email: user.email, password: "DependencyCheck123!" } })
raise "Sign-in failed: #{session.response.status}" unless session.response.redirect?
session.get("/categories")
raise "Authenticated page failed: #{session.response.status}" unless session.response.status == 200
puts "Smoke checks passed: SQLite, models, password verification, sign-in and authenticated page."
