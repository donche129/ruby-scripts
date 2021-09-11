# TO DO: add screenshots

require 'spec_helper'

feature "Check PS5 availability on GameStop" do

  before(:all) do
    if ENV["ALERTEMAIL"] == '' || ENV["ALERTPASS"] == ''
      Log.info 'No email info was passed on execution, alert will not be sent.'
      @email_info_found = false
    end

    if ENV["GSEMAIL"] == '' || ENV["GSPASS"] == ''
      Log.info 'No login info was passed on execution, will not sign in to check out.'
      @login_info_found = false
    end
  end

  scenario "GameStop" do
    sign_in
    find_ps5
    wait_for_stock
    proceed_to_checkout
    alert_user
  end

end

def sign_in
  visit 'https://www.gamestop.com/login'
  find('input[type="email"]').set(ENV["GSEMAIL"])
  find('input[type="password"]').set(ENV["GSPASS"])
  find('[class*="sign-in-submit"]', :text => 'SIGN IN').click
  sleep 10 # TO DO: check loading done function instead of sleep
end

def find_ps5
  begin
    # visit 'https://www.gamestop.com/video-games/playstation-5/products/marvels-spider-man-miles-morales-ultimate-edition---playstation-5/11108812.html?condition=New'
    visit 'https://www.gamestop.com/consoles-hardware/playstation-5/consoles/products/sony-playstation-5-console/11108140.html?condition=New'
    page.should have_text 'Sony PlayStation 5 Console'
  rescue Exception => e
    Log.error 'Trouble reaching PS5 product page. Page may have changed content or URL.'
    fail 'Could not load PS5 page.'
  end
end

def wait_for_stock
  sold_out = true
  while sold_out
    begin
      page.should have_css('[class^="add-to-cart-buttons"]', :text => 'ADD TO CART')
      Log.info 'Alert! PS5 now in stock! Adding to cart...'
      find('[class^="add-to-cart-buttons"]', :text => 'ADD TO CART').click
      sleep 5 # TO DO: check loading done function instead of sleep
      page.should have_css('[class^="minicart-quantity"]', :text => '1')
      sold_out = false
      Log.info 'PS5 added to cart.'
    rescue Exception
      page.should have_css('[class^="add-to-cart-buttons"]', :text => 'NOT AVAILABLE')
      Log.info 'PS5 stock is currently sold out.'
      sleep 60
      retry
    end
  end
end

def proceed_to_checkout
  if @login_info_found == false
    Log.info 'No login info found. Will not check out.'
  else
    visit 'https://www.gamestop.com/cart/'
    find('[class="checkout-btn-text-mobile"]', :text => 'PROCEED TO CHECKOUT').click
    Log.info 'PS5 ready to checkout!'
  end
end

def alert_user
  if @email_info_found == false
    Log.info 'Alert email not sent.'
  else
    Mail.deliver do
         to 'donaldcherestal@gmail.com'
       from 'donaldcherestal@gmail.com'
    subject 'PS5 added to GameStop cart'
       body 'Ready to checkout! Hurry!'
    end
    Log.info 'Alert email sent.'
  end
  while true
    Log.info 'Waiting for you to check out. Terminate the script when you have completed your order.'
    sleep 600
  end
end
