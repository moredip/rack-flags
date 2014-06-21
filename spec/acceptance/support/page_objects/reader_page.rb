class ReaderPage
  include RSpec::Matchers
  include Capybara::DSL

  def self.visiting( path = "/" )
    page = self.new(path)
    page.visit_page
    yield page
  end

  def initialize( path )
    @path = path
  end

  def visit_page
    visit(@path)
  end

  def verify_flag_is_off(flag_name)
    expect(page).to have_content("#{flag_name} is off")
  end

  def verify_flag_is_on(flag_name)
    expect(page).to have_content("#{flag_name} is on")
  end

end
