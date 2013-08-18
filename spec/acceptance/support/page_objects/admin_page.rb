class AdminPage
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
    visit @path
  end

  def turn_on_flag_name(flag_name)
    section_for_flag_named(flag_name).choose('On')
    update_button.click
  end
  
  def turn_off_flag_name(flag_name)
    section_for_flag_named(flag_name).choose('Off')
    update_button.click
  end


  def update_button 
    page.find('input[type="submit"]')
  end

  def section_for_flag_named(flag_name)
    page.find(%Q|section[data-flag-name="#{flag_name}"]|)
  end

  def verify_flag_section( flag_name, expected_state )
    section = section_for_flag_named( flag_name )

    case expected_state.to_sym
    when :default
      section.find('label.default input').should be_checked

      section.find('label.on input').should_not be_checked
      section.find('label.off input').should_not be_checked
    when :on
      section.find('label.on input').should be_checked

      section.find('label.default input').should_not be_checked
      section.find('label.off input').should_not be_checked
    when :off
      section.find('label.off input').should be_checked

      section.find('label.default input').should_not be_checked
      section.find('label.on input').should_not be_checked
    else 
      raise "unrecognized state '#{expected_state}'"
    end
  end

  def verify_status_code_is(expected_status_code)
    status_code.should == expected_status_code
  end

end
