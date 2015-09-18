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

  def test_readings_destroyed_with_lesson
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading")
    before = Reading.count
    l.readings << r
    l.destroy
    assert_equal before - 1, Reading.count
  end

  def test_associate_courses_with_lesssons
    c = Course.create(name: "First Course")
    l = Lesson.create(name: "First Lesson")
    c.lessons << l
    assert c.reload.lessons.include?(l)
  end

  def test_lessons_destroyed_with_course
    c = Course.create(name: "First Course")
    l = Lesson.create(name: "First Lesson")
    before = Lesson.count
    c.lessons << l
    c.destroy
    assert_equal before-1, Lesson.count
  end

end
