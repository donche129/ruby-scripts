# TO DO: sign in before adding to cart
# TO DO: add screenshots

require 'spec_helper'

feature "Check PS5 availability on Best Buy" do

  before(:all) do
    if ENV["ALERTEMAIL"] == '' || ENV["ALERTPASS"] == ''
      Log.info 'No email info was passed on execution, alert will not be sent.'
      @email_info_found = false
    end

    if ENV["BBEMAIL"] == '' || ENV["BBPASS"] == ''
      Log.info 'No login info was passed on execution, will not sign in to check out.'
      @login_info_found = false
    end
  end

  scenario "Bestbuy" do
    open_site
    wait_for_stock
    proceed_to_checkout
    alert_user
  end

end

def open_site
  begin
    visit 'https://www.bestbuy.com/site/sony-playstation-5-console/6426149.p?skuId=6426149'
    page.should have_text 'Sony - PlayStation 5 Console'
  rescue Exception => e
    Log.error 'Trouble reaching PS5 product page. Page may have changed content or URL.'
    fail 'Could not load PS5 page.'
  end
end

def wait_for_stock
  sold_out = true
  while sold_out
    begin
      page.should have_text('Add to Cart')
      Log.info 'Alert! PS5 now in stock! Adding to cart...'
      find_button('Add to Cart').click
      page.should have_css('[class="cart-icon"]', :text => '1')
      sold_out = false
      Log.info 'PS5 added to cart.'
    rescue Exception
      page.should have_text('Sold Out')
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
    visit 'https://www.bestbuy.com/cart'
    find('[class="availability__fulfillment"]', :text => 'FREE Shipping').find('[class^="availability__radio"]').click
    find_button('Checkout').click
    find('input[type="email"]').set(ENV["BBEMAIL"])
    find('input[type="password"]').set(ENV["BBPASS"])
    find_button('Sign In').click
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
    subject 'PS5 added to Best Buy cart'
       body 'Ready to checkout! Hurry!'
    end
    Log.info 'Alert email sent.'
  end
  while true
    Log.info 'Waiting for you to check out. Terminate the script when you have completed your order.'
    sleep 600
  end
end
