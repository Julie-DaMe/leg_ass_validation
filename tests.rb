require 'minitest/autorun'
require 'minitest/pride'
require './migration'
require './application'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)

class ApplicationTest < Minitest::Test

  def test_to_associate_terms_with_schools
    school = School.create(name: "Elkins")
    term = Term.create(name: "First Term")

    school.add_term(term)
    assert school.reload.terms.include?(term)
    assert_equal school, term.reload.school
  end

  def test_to_associate_terms_with_courses
    term = Term.create(name: "First Term")
    course = Course.create(name: "Math")

    term.add_course(course)
    assert term.reload.courses.include?(course)
    assert_equal term, course.reload.term
  end

  def test_terms_cannot_be_deleted
    term = Term.create(name: "First Term")
    course = Course.create(name: "Math101")
    before = Term.count

    term.add_course(course)
    term.destroy
    refute_equal Term.count, before-1
  end

  def test_to_associate_course_with_courses_student
    course = Course.create(name: "Math101")
    student = CourseStudent.create()

    course.course_students << student
    assert course.reload.course_students.include?(student)
  end

  def test_courses_cannot_be_deleted
    course = Course.create(name: "Math101")
    student = CourseStudent.create()
    before = Course.count

    course.course_students << student
    course.destroy
    refute_equal Course.count, before-1
  end

  def test_assignmnets_are_destroyed_wtih_courses
    assignment = Assignment.create(name: "plus")
    course = Course.create(name: "Math101")
    before = Course.count

    course.assignments << assignment
    course.destroy
    assert_equal before-1, Course.count
  end

  def test_associate_lessons_with_pre_class_assignments
    lesson = Lesson.create(name: "addition")
    assignment = Assignment.create(name: "plus")

    assignment.lessons << lesson
    assert_equal [lesson], assignment.lessons
  end

  def test_that_school_has_many_courses_through_terms
    s = School.create(name: "Elkins")
    c = Course.create(name: "Math101")
    t = Terms.create(name: "First Term")

    s.terms << c
    assert_equal [t], t.courses
  end





















end
