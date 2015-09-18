require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class ApplicationTest < Minitest::Test

  def test_associate_lessons_with_readings
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    # l.add_reading(r)
    # assert_equal [r], Lesson.find(l.id).readings
    l.readings << r
    assert l.reload.readings.include?(r)
  end

end
