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
    r = Reading.create(caption: "First Reading", order_number: 109, lesson_id: 186, url: "https://holladolla.com")
    l.readings << r
    assert l.reload.readings.include?(r)
  end

  def test_readings_destroyed_with_lesson
    l = Lesson.create(name: "First Lesson")
    r = Reading.create(caption: "First Reading", order_number: 109, lesson_id: 486, url: "https://holladolla.com")
    before = Reading.count
    l.readings << r
    l.destroy
    assert_equal before - 1, Reading.count
  end

  def test_associate_courses_with_lesssons
    c = Course.create(name: "First Course", course_code: "abv123")
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
    c = Course.create(name: "First Course", course_code: "abr345")
    m = CourseInstructor.create()
    c.course_instructors << m
    assert c.course_instructors.include?(m)
  end

  def test_cannot_destroy_courses_with_students
    c = Course.create(name: "First Course", course_code: "abv133")
    j = CourseStudent.create()
    before = Course.count
    c.course_students << j
    c.destroy
    refute_equal Course.count, before-1
  end

  def test_associate_lessons_with_in_class_assignments
    my_lesson = Lesson.create(name: "First Lesson")
    i = Assignment.create(name: "In-Class Assignment", course_id: 1, percent_of_grade: 10.0)
    i.lessons << my_lesson
    assert_equal [my_lesson], i.lessons
  end

  def test_course_has_readings_through_lessons
    c = Course.create(name: "First Course", course_code: "abw153")
    r = Reading.create(order_number: 123, lesson_id: 146, url: "https://rickrolled.com")
    l = Lesson.create(name: "Archery")

    l.readings << r
    c.lessons << l
    assert_equal [r], c.readings
  end

  def test_validates_schools_name
    s = School.create(name: "Apex High")
    refute_equal s.name, nil
  end

  def test_validates_term_name_starts_on_ends_on_school_id
    fall = Term.create(name: "Apex High", starts_on: Date.today, ends_on: Date.today, school_id: 1)
    refute_equal fall.name, nil
    refute_equal fall.starts_on, nil
    refute_equal fall.ends_on, nil
    refute_equal fall.school_id, nil
  end

  def test_validates_user_first_name_last_name_email
    u = User.create(first_name: "Julie", last_name: "David", email: "julie.angela.david@gmail.com")

    refute_equal u.first_name, nil
    refute_equal u.last_name, nil
    refute_equal u.email, nil
  end

  def test_validate_user_email_uniqueness
    User.create(first_name: "Julie", last_name: "David", email: "julie.angela.david@gmail.com")
    j = User.new(first_name: "Julie", last_name: "David", email: "julie.angela.david@gmail.com")

    refute j.save
  end

  def test_user_email_address_correctness
    User.create(first_name: "Julie", last_name: "David", email: "julie.angela.david@gmail.com")
    l = User.new(first_name: "Julie", last_name: "David", email: "julie.angela.david@@gmail.com")
    i = User.new(first_name: "Julie", last_name: "David", email: "julie.angela.david@gmailcom")
    e = User.new(first_name: "Julie", last_name: "David", email: "julie.angela.davidgmail.com")
    refute l.save
    refute i.save
    refute e.save
  end

  def test_user_photo_url
    assert User.create(first_name: "Julie", last_name: "David", email: "j@gmail.com", photo_url: "http://photobucket.com")
    assert User.create(first_name: "Julie", last_name: "David", email: "d@gmail.com", photo_url: "https://photobucket.com")
    l = User.new(first_name: "Julie", last_name: "David", email: "id@@gmail.com", photo_url: "htttp://photobucket.com")
    i = User.new(first_name: "Julie", last_name: "David", email: "vid@gmailcom", photo_url: "://photobucket.comhttp://")
    e = User.new(first_name: "Julie", last_name: "David", email: "avidgmail.com", photo_url: "hhttps://photobucket.com")
    refute l.save
    refute i.save
    refute e.save
  end

  def test_validates_assignment_course_id_name_percent_of_grade
    a = Assignment.new(course_id: 1, name: "Ruby101", percent_of_grade: 10.0)
    assert a.save
  end

  def test_assignment_name_must_be_unique_within_course_id
    a = Assignment.new(course_id: 1, name: "Ruby102", percent_of_grade: 10.0)
    b = Assignment.new(course_id: 1, name: "Ruby102", percent_of_grade: 10.0)
    assert a.save
    refute b.save
  end

#Da-Me's tests:

  def test_to_associate_terms_with_schools
    school = School.create(name: "Elkins")
    term = Term.create(name: "First Term")

    school.add_term(term)
    assert school.reload.terms.include?(term)
    assert_equal school, term.reload.school
  end

  def test_to_associate_terms_with_courses
    term = Term.create(name: "First Term")
    course = Course.create(name: "Math", course_code: "Yay675")

    term.add_course(course)
    assert term.reload.courses.include?(course)
    assert_equal term, course.reload.term
  end

  def test_terms_cannot_be_deleted
    term = Term.create(name: "First Term")
    course = Course.create(name: "Math101", course_code: "hey098")
    before = Term.count

    term.add_course(course)
    term.destroy
    refute_equal Term.count, before-1
  end

  def test_to_associate_course_with_courses_student
    course = Course.create(name: "Math101", course_code: "wha909")
    student = CourseStudent.create()

    course.course_students << student
    assert course.reload.course_students.include?(student)
  end

  def test_courses_cannot_be_deleted
    course = Course.create(name: "Math101", course_code: "hey678")
    student = CourseStudent.create()
    before = Course.count

    course.course_students << student
    course.destroy
    refute_equal Course.count, before-1
  end

  def test_assignmnets_are_destroyed_wtih_courses
    assignment = Assignment.create(name: "plus")
    course = Course.create(name: "Math101", course_code: "nay345")
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
    c = Course.create(name: "Math101", course_code: "hey101")
    t = Term.create(name: "First Term")

    t.courses << c
    s.terms << t
    assert [c], s.courses
  end

  def test_validation_for_name
    l = Lesson.new()
    refute l.save
  end

  def test_validation_for_order_number_lesson_id_url
    Reading.new(order_number: 11, lesson_id:12 , url: "www.yaboi.com")
    r = Reading.new(order_number: "",lesson_id: "",url: "")
    refute r.save
  end

  def test_validation_of_regex
    Reading.new(url: "https//rickroll.com")
    r = Reading.new(url: "www.rickroll.com")
    refute r.save
  end

  def test_courses_have_course_code_and_name
    Course.new(name: "Math101", course_code: "HEY111")
    c = Course.new(name: "", course_code: "")
    refute c.save
  end

  def test_course_code_uniqueness_through_terms
    c1 =  Course.create(name: "Science", course_code: "hey")
    c = Course.create(name: "Math101", course_code: "hey")

    refute c1 == c
  end

  def test_course_code_begins_with_three_letters_ends_with_three_numbers
    Course.new(name: "Math101", course_code: "REG123")
    c = Course.new(name: "Math101", course_code: "123REG")
    refute c.save
  end

end
