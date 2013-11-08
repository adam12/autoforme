require './spec/spec_helper'

describe AutoForme do
  before(:all) do
    db_setup(:artists=>[[:name, :string]], :albums=>[[:name, :string], [:artist_id, :integer, {:table=>:artists}]])
    model_setup(:Artist=>[:artists], :Album=>[:albums, [[:many_to_one, :artist]]])
  end
  after(:all) do
    Object.send(:remove_const, :Album)
    Object.send(:remove_const, :Artist)
  end

  it "should have basic many to one associations working" do
    app_setup do
      autoforme Artist
      autoforme Album do
        columns [:name, :artist]
      end
    end

    visit("/Artist/new")
    fill_in 'Name', :with=>'Artist1'
    click_button 'Create'
    fill_in 'Name', :with=>'Artist2'
    click_button 'Create'

    visit("/Album/new")
    fill_in 'Name', :with=>'Album1'
    select 'Artist1'
    click_button 'Create'

    click_link 'Show'
    select 'Album1'
    click_button 'Show'
    page.html.should =~ /Name.+Album1/m
    page.html.should =~ /Artist.+Artist1/m

    click_link 'Edit'
    select 'Album1'
    click_button 'Edit'
    fill_in 'Name', :with=>'Album1b'
    select 'Artist2'
    click_button 'Update'

    click_link 'Search'
    fill_in 'Name', :with=>'1b'
    select 'Artist2'
    click_button 'Search'
    all('td').map{|s| s.text}.should == ["Album1b", "Artist2", "Show", "Edit", "Delete"]

    click_link 'Album'
    all('td').map{|s| s.text}.should == ["Album1b", "Artist2", "Show", "Edit", "Delete"]
  end

  it "should be able to used specified name formatting in other model" do
    app_setup do
      autoforme Artist do
        display_name{|obj| obj.name * 2}
      end
      autoforme Album do
        columns [:name, :artist]
      end
    end

    visit("/Artist/new")
    fill_in 'Name', :with=>'A1'
    click_button 'Create'
    fill_in 'Name', :with=>'A2'
    click_button 'Create'

    visit("/Album/new")
    fill_in 'Name', :with=>'Album1'
    select 'A1A1'
    click_button 'Create'

    click_link 'Show'
    select 'Album1'
    click_button 'Show'
    page.html.should =~ /Name.+Album1/m
    page.html.should =~ /Artist.+A1A1/m

    click_link 'Edit'
    select 'Album1'
    click_button 'Edit'
    fill_in 'Name', :with=>'Album1b'
    select 'A2A2'
    click_button 'Update'

    click_link 'Search'
    fill_in 'Name', :with=>'1b'
    select 'A2A2'
    click_button 'Search'
    all('td').map{|s| s.text}.should == ["Album1b", "A2A2", "Show", "Edit", "Delete"]

    click_link 'Album'
    all('td').map{|s| s.text}.should == ["Album1b", "A2A2", "Show", "Edit", "Delete"]
  end

  it "should be able to used specified name formatting for current association" do
    app_setup do
      autoforme Artist
      autoforme Album do
        columns [:name, :artist]
        column_options :artist=>{:name_method=>lambda{|obj| obj.name * 2}}
      end
    end

    visit("/Artist/new")
    fill_in 'Name', :with=>'A1'
    click_button 'Create'
    fill_in 'Name', :with=>'A2'
    click_button 'Create'

    visit("/Album/new")
    fill_in 'Name', :with=>'Album1'
    select 'A1A1'
    click_button 'Create'

    click_link 'Show'
    select 'Album1'
    click_button 'Show'
    page.html.should =~ /Name.+Album1/m
    page.html.should =~ /Artist.+A1A1/m

    click_link 'Edit'
    select 'Album1'
    click_button 'Edit'
    fill_in 'Name', :with=>'Album1b'
    select 'A2A2'
    click_button 'Update'

    click_link 'Search'
    fill_in 'Name', :with=>'1b'
    select 'A2A2'
    click_button 'Search'
    all('td').map{|s| s.text}.should == ["Album1b", "A2A2", "Show", "Edit", "Delete"]

    click_link 'Album'
    all('td').map{|s| s.text}.should == ["Album1b", "A2A2", "Show", "Edit", "Delete"]
  end

  it "should be able to eager load associations when loading model" do
    app_setup do
      autoforme Artist
      autoforme Album do
        columns [:name, :artist]
        eager :artist
        display_name{|obj| "#{obj.associations[:artist].name}-#{obj.name}"}
      end
    end

    visit("/Artist/new")
    fill_in 'Name', :with=>'A1'
    click_button 'Create'
    fill_in 'Name', :with=>'A2'
    click_button 'Create'

    visit("/Album/new")
    fill_in 'Name', :with=>'Album1'
    select 'A1'
    click_button 'Create'

    click_link 'Show'
    select 'A1-Album1'
    click_button 'Show'
    page.html.should =~ /Name.+Album1/m
    page.html.should =~ /Artist.+A1/m

    click_link 'Edit'
    select 'A1-Album1'
    click_button 'Edit'
    fill_in 'Name', :with=>'Album1b'
    select 'A2'
    click_button 'Update'

    click_link 'Search'
    fill_in 'Name', :with=>'1b'
    select 'A2'
    click_button 'Search'
    all('td').map{|s| s.text}.should == ["Album1b", "A2", "Show", "Edit", "Delete"]

    click_link 'Album'
    all('td').map{|s| s.text}.should == ["Album1b", "A2", "Show", "Edit", "Delete"]

    click_link 'Delete'
    select 'A2-Album1b'
    click_button 'Delete'
  end
end