require 'rails_helper'

feature 'Notifications' do
  given(:user)     { create :user }
  given(:user_two) { create :user }
  given!(:post)    { create(:post, user: user) }

  # As a User
  # So that I can find out when someone comments on my post
  # I want to display the notification count on navbar
  scenario 'can see the number of notifications' do
    built_messages = build_list(:comment, 10, post: post, user: user_two)

    log_in_as user_two

    built_messages.each do |message|
      write_comment_with message
    end

    log_out
    log_in_as user

    expect(page).to have_icon_flag
    expect(find('.dropdown-toggle')).to have_content '10'
  end

  # As a User
  # So that I can see only unread notifications
  # I want to mark visited notifications as read
  scenario 'can see only unread notifications' do
    built_messages = build_list(:comment, 9, post: post, user: user_two)

    log_in_as user_two

    built_messages.each do |message|
      write_comment_with message
    end

    log_out
    log_in_as user

    4.times do
      click_link "#{user_two.username} has commented on your post", match: :first
    end

    expect(page).to have_current_path post_path(post)
    expect(find('.dropdown-toggle')).to have_content '5'
  end
end
