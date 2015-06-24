describe 'sanity checking' do
  it 'should serve the index page', :js do
    visit root_path
    expect(page).to have_content('kirill')
  end
end