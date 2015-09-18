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
    course = Course.create(name: "Math")
    term = Term.create(name: "First Term")

    term.add_course(course)
    assert term.reload.courses.include?(course)
    assert_equal term, course.reload.term
  end
end
