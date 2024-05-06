require 'rails_helper'

RSpec.describe 'Currency conversion process', type: :feature do
  let(:yesterday) { (Date.today - 1).strftime("%Y-%m-%d") }
  let(:seven_days_ago) { (Date.today - 7).strftime("%Y-%m-%d") }
  let(:thirty_days_ago) { (Date.today - 30).strftime("%Y-%m-%d") }

  before do
    allow(CurrencyApiClient).to receive(:supported_currencies).and_return({'USD' => 'US Dollar', 'EUR' => 'Euro'})
    allow(CurrencyApiClient).to receive(:convert).and_return({'data' => {'EUR' => {'value' => 92.66}}})
    allow(CurrencyApiClient).to receive(:latest_rate).and_return(0.93)
    allow(CurrencyApiClient).to receive(:historical_rates).with([yesterday, seven_days_ago, thirty_days_ago], "USD", "EUR").and_return({
      yesterday => 0.93, 
      seven_days_ago => 0.93, 
      thirty_days_ago => 0.92
    })    
  end

  it 'converts currencies and displays results' do
    visit root_path
    expect(page).to have_content('ExchangeGO')

    fill_in 'Amount to Convert', with: '100'
    select 'US Dollar', from: 'Convert from'
    select 'Euro', from: 'Convert to'
    click_button 'Convert'

    expect(page).to have_content('Conversion Rate:')
    expect(page).to have_content('100.0 USD = 92.66 EUR')
    expect(page).to have_content('Latest Rate:')
    expect(page).to have_content('Today: 0.93 EUR')
    expect(page).to have_content('Historical Rates:')
    expect(page).to have_content('Yesterday: 0.93 EUR')
    expect(page).to have_content('Seven days ago: 0.93 EUR')
    expect(page).to have_content('Thirty days ago: 0.92 EUR')
  end
end
