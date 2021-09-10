require 'spec_helper'

feature "Check PS5 availability on Bestbuy" do

  before(:all) do
    if ENV["ALERTEMAIL"] == nil || ENV["ALERTPASS"] == nil
      Log.info 'No email info was passed on execution, alert will not be sent.'
      @email_info_found = false
    end
  end

  scenario "Bestbuy" do
    open_bestbuy
    wait_for_stock
    proceed_to_checkout
    alert_user
  end

end

def open_bestbuy
  begin
    visit 'https://www.bestbuy.com/site/marvels-spider-man-miles-morales-standard-launch-edition-playstation-5/6430146.p?skuId=6430146'
    # visit 'https://www.bestbuy.com/site/sony-playstation-5-console/6426149.p?skuId=6426149'
    # page.should have_text 'Sony - PlayStation 5 Console'
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
  visit 'https://www.bestbuy.com/cart'
  find('[class="availability__fulfillment"]', :text => 'FREE Shipping').find('[class^="availability__radio"]').click
  find_button('Checkout').click
  find('input[type="email"]').set(ENV["BBEMAIL"])
  find('input[type="password"]').set(ENV["BBPASS"])
  find_button('Sign In').click
  Log.info 'PS5 ready to checkout!'
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
  sleep 60
end
