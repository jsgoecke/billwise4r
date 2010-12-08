require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Billwise" do
  before(:all) do
    config = YAML.load(File.open('spec/config/config.yml'))
    @options = config.merge!({ :log => false })
                               
    @billwise = Billwise.new @options
  end
  
  it "should create a Billwise object" do
    @billwise = Billwise.new @options
    @billwise.instance_of?(Billwise).should == true
  end
  
  it "should raise errors if required params are not passed" do
    begin
      Billwise.new
    rescue => e
      e.to_s.should == "You must provide Billwise connection parameters."
    end
    
    begin
      Billwise.new({ :companyCd => 100 })
    rescue => e
      e.to_s.should == "You must provide a valid username."
    end
  end
  
  it "should find a valid customer" do
    result = @billwise.find_customer({ :customerCd => '000155' })
    result[:customer_cd].should == "000155"
  end
  
  it "should find that customers invoices" do
    result = @billwise.find_invoices({ :customerCd => '000155' })
    result[0][:invoice_number].should == "STMNT-201005"
  end
  
  it "should find services" do
    result = @billwise.find_services({ :customerCd => '000155',
                                       :serviceId  => 'A000000000046590',
                                       :status     => 'A' })
    result[:service_id].should == 'A000000000046590'
  end
end