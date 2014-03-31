require 'test_helper'

class InjectTest < CapybaraTestCase
  def setup
    super

    @twitter_user = CONFIG[:twitter]
  end

  def click_show_tweet(idx: 0)
    all_with_wait('.hidden-message')[idx].find('a').click
  end

  def assert_tweet_filtered(idx)
    wait_until { all('#stream-items-id .tweet')[idx].text == "#{@twitter_user[:screen_name]}'s tweet has been filtered. Show?" }
  end

  def assert_tweet_not_filtered
    wait_until { get_js("$($('.tweet:visible')[0]).text()").include?('@garfield hello') }
  end

  def test
    visit_options_page
    add_filtered_phrase('reply4')
    login_twitter(@twitter_user[:screen_name], @twitter_user[:password])
    visit_twitter
    assert_tweet_filtered(1)

    visit_options_page
    remove_all_filters
    add_filtered_user(@twitter_user[:screen_name])
    visit_twitter

    # tweet filtered
    assert_tweet_filtered(0)
    click_show_tweet
    assert_tweet_not_filtered

    # mutation observer will run filter on simple tweets
    send_keyboard_shortcut('gh')
    send_keyboard_shortcut('gp')
    all('.tweet')[1].click
    assert_has_css('.simple-tweet .tf-el')
    # mutation observer will filter expanded conversations
    all('.tweet').each do |tweet|
      next if has_class?(tweet, 'simple-tweet')
      assert_text_include('filtered', tweet)
    end

    # make new tweet
    send_keyboard_shortcut('gh')
    click('#global-new-tweet-button')
    has_css?('#tweet-box-global', visible: true)
    page.execute_script("jQuery('#tweet-box-global').text('zzzzz')")
    click('.tweet-action')
    assert_tweet_filtered(0)

    click_show_tweet
    first('.js-action-del').click
    click('.delete-action')
    assert_tweet_filtered(0)

    # test that mentions and interactions page don't get filter applied
    send_keyboard_shortcut('gc')
    assert_has_no_css('.tf-el')
    wait_for_new_url(all('.list-link').last)
    assert_has_no_css('.tf-el')

    send_keyboard_shortcut('gp')
    # test that click handler still works after page change
    sleep 1
    click_show_tweet
    assert_tweet_not_filtered

    lambda do
      toggle_hide_el = find('.toggle-hide')

      assert_text('Unhide', toggle_hide_el)
      toggle_hide_el.click
      assert_text('Hide', toggle_hide_el)

      toggle_hide_el.click
      confirm_accept("Hide all of #{@twitter_user[:screen_name]}'s tweets? This won't unfollow or block him/her.")
      assert_tweet_filtered(0)
    end.()

    # test hide mentions
    visit_options_page
    clear_filtered_users
    add_filtered_user('garfield')
    click('.hide-mentions-input')

    visit("https://twitter.com/#{@twitter_user[:screen_name]}")
    filtered_tweet = first('.tweet')
    assert_text_include('filtered', filtered_tweet)

    filtered_tweet.find('a').click
    assert_text_include('@garfield', filtered_tweet)

    # test hide completely
    visit_options_page
    clear_filtered_users
    add_filtered_user(@twitter_user[:screen_name])
    click('.hide-completely-input')
    assert_settings_saved_alert

    visit_twitter
    tweet_classes = %w(.tweet)
    tweet_classes.each do |selector|
      assert_has_no_css(selector)
    end

    visit_options_page
    click('.enable-input')
    visit_twitter
    assert_has_no_css('.tf-el')

    tweet_classes.each do |selector|
      assert_has_css(selector)
    end
  end
end