require 'test_helper'

class OptionsTest < CapybaraTestCase
  def user_count
    all('.filtered-users li').size
  end

  def test
    visit_options_page
    lambda do
      # enable filters
      enable_input = find('.enable-input')
      enable_input.click unless enable_input.selected?
    end.()
    clear_filtered_users

    # empty usernames don't get added
    add_filtered_user(' <> ')
    assert_equal(0, user_count)
    add_filtered_user(' @dog ')
    # input cleared after successful input
    assert_equal('', get_val('.filtered-users-input'))
    # shows saved alert
    assert_settings_saved_alert
    # test added entry
    screen_name_el = find('.screen-name')
    assert_text('@dog', screen_name_el)
    assert_equal('http://twitter.com/dog', screen_name_el[:href])
    # duplicates don't get added
    add_filtered_user('dog')
    assert_equal(1, user_count)
    # test close button
    click('.filtered-users .close')
    assert_equal(0, user_count)

    # test filtered phrases
    add_filtered_phrase('  ')
    add_filtered_phrase(' Dog ')
    assert_settings_saved_alert
    add_filtered_phrase('dog')
    assert_equal(1, all('.filtered-phrases li').size)
    click('.filtered-phrases .close')
    assert_equal(0, all('.filtered-phrases li').size)
  end
end