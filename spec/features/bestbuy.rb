require 'spec_helper'

feature "Check PS5 availability on Bestbuy" do

  scenario "Bestbuy" do
    open_bestbuy
    wait_for_stock
    alert_user
  end

end

def open_bestbuy
  begin
    visit 'https://www.bestbuy.com/site/sony-playstation-5-console/6426149.p?skuId=6426149'
    page.should have_text 'Sony - PlayStation 5 Console'
  rescue Exception => e
    Log.error 'Trouble reaching PS5 product page. Page may have changed content.'
    fail 'Could not load PS5 page'
  end
end

def wait_for_stock
  sold_out = true
  while sold_out
    begin
      page.should have_text('Add to Cart')
      sold_out = false
      Log.info 'Alert! PS5 now in stock!'
    rescue Exception
      page.should have_text('Sold Out')
      Log.info 'PS5 stock is currently sold out'
      sleep 60
      retry
    end
  end
end

def alert_user
  visit 'https://www.youtube.com/watch?v=CEvzFcqKbXw'
  find('div[id="player-container-inner"]').click
  sleep 60
end
