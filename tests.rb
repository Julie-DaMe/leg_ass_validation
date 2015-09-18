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

  def test_associate_course_with_course_instructors
    c = Course.create(name: "First Course")
    m = CourseInstructor.create()
    c.course_instructors << m
    assert c.course_instructors.include?(m)
  end

  def test_cannot_destroy_courses_with_students
    c = Course.create(name: "First Course")
    j = CourseStudent.create()
    before = Course.count
    c.course_students << j
    c.destroy
    refute_equal Course.count, before-1
  end

  def test_associate_lessons_with_in_class_assignments
    my_lesson = Lesson.create(name: "First Lesson")
    i = Assignment.create(name: "In-Class Assignment")
    i.lessons << my_lesson
    #assert i.in_class_assignments.include?(my_lesson)
    assert_equal [my_lesson], i.lessons
  end

  def test_course_has_readings_through_lessons
    c = Course.create(name: "First Course")
    r = Reading.create()
    l = Lesson.create()

    l.readings << r
    c.lessons << l
    assert_equal [r], c.readings
  end

  def test_validates_schools_name
    s = School.create(name: "Apex High")
    refute_equal s.name, nil
  end




end
