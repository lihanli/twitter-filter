require 'test_helper'

class OptionsTest < CapybaraTestCase
  def user_count
    all('.filtered-users li').size
  end

  def test
    visit_options_page
    clear_filtered_users

    # empty usernames don't get added
    add_filtered_user(' <> ')
    assert_equal(0, user_count)
    add_filtered_user(' @dog ')
    # input cleared after successful input
    assert_equal('', get_val('.filtered-user-input'))
    # shows saved alert
    assert_settings_saved_alert
    # whitespace gets trimmed
    assert_text('@dog', find('.screen-name'))
    # test close button
    click('.filtered-users .close')
    assert_equal(0, user_count)
  end
end