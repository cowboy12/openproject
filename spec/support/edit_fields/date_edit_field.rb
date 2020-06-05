require_relative './edit_field'

class DateEditField < EditField
  def datepicker
    @datepicker ||= ::Components::Datepicker.new modal_selector
  end

  def modal_selector
    '.datepicker-modal'
  end

  def input_selector
    "input[name=#{property_name}]"
  end

  def modal_element
    page.find(modal_selector)
  end

  def within_modal(&block)
    page.within(modal_selector, &block)
  end

  def input_element
    modal_element.find(input_selector)
  end

  def active?
    page.has_selector?("#{modal_selector} #{input_selector}")
  end

  def update(value, save: true, expect_failure: false)
    # Retry to set attributes due to reloading the page after setting
    # an attribute, which may cause an input not to open properly.
    retry_block do
      activate_edition
      within_modal do
        if value.is_a?(Array)
          value.each {|el| select_value(el)}
        else
          select_value value
        end
      end

      save! if save
      expect_state! open: expect_failure
    end
  end

  def expect_value(value)
    expect
    expect(input_element.text).to eq(value)
  end

  def select_value(value)
    datepicker.set_date value
  end

  def save!
    submit_by_click
  end

  def submit_by_click
    scroll_to_and_click action_button('Save')
  end

  def cancel_by_click
    scroll_to_and_click action_button('Cancel')
  end

  def clear_changes
    scroll_to_and_click action_button('Clear')
  end

  def action_button(text)
    page.find("#{modal_selector} .datepicker-modal--action", text: text)
  end
end
