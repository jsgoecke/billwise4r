class Billwise
  ##
  # Instantiates a new Billwise class
  #
  def initialize(params={})
    # Make sure all params we need are here or raise an error
    check_initialization_params(params)
    
    @companyCd = params[:companyCd]    
    log        = params[:log]       || false
    log_level  = params[:log_level] || false
    
    Savon.configure do |config|
      config.log       = log
      config.log_level = log_level
    end
    
    @soap_endpoint  = URI.parse params[:endpoint] || 'https://cwa021.connect4billing.com/axis2/services/ConnectSmService.ConnectSmServiceHttpSoap12Endpoint/'
    @soap_namespace = params[:namespace] || 'http://connectsm.ws.bwse.com/xsd'
    @soap_version   = 2
    
    # Build our SOAP driver    
    @soap_driver = Savon::Client.new do
      wsse.credentials params[:username] , params[:password]
      wsdl.document = params[:wsdlUrl] || 'https://cwa021.connect4billing.com/axis2/services/ConnectSmService?wsdl'
    end
        
    @tag_order  = tag_order
    
    MultiXml.parser = :nokogiri
  end
  
  ##
  # A catch all for the methods defined by the WSDL
  # refer to the Billwise API documentation for details
  #
  # @return [Hash] the Billwise response
  def method_missing(method, params)
    response = @soap_driver.request(:xsd, method) do |soap, wsse|
      soap.version = @soap_version
      soap.endpoint = @soap_endpoint
      soap.namespaces["xmlns:xsd"] = @soap_namespace
      
      fields = { :companyCd => @companyCd }.merge!(params)
      fields.merge!({ :order! => @tag_order[method] }) if @tag_order[method]
      
      soap.body = fields
    end
    response.to_hash["#{method}_response".to_sym][:return]
  end
    
  private
  
  ##
  # Checks that the required params have been provided, or rasies an error
  def check_initialization_params(params={})
    raise ArgumentError, "You must provide Billwise connection parameters." if params.length == 0
    %w(companyCd username password).each { |param| raise ArgumentError, "You must provide a valid #{param}." if params[param.to_sym].nil? }
  end
  
  ##
  # Traverses the WSDL to create a hash of methods and their ordered parameters
  # only necessary since the Billwise SOAP/XML API requires attributes in order
  # and the Ruby MRI likes to alphabetize, so Savon allows us to set a specific
  # order when building the XML
  #
  # @return [Hash] the methods and their ordered parameters
  def tag_order
    actions = {}
    MultiXml.parse(@soap_driver.wsdl.to_xml)['definitions']['types']['schema'][2]['element'].each do |action|
      attributes = []
      if action['complexType']['sequence']['element'].instance_of?(Hash)
        attributes << action['complexType']['sequence']['element']['name'].to_sym
      else
        action['complexType']['sequence']['element'].each { |item| attributes << item['name'].to_sym }
      end
      actions[decamelize(action['name']).to_sym] = attributes
    end
    actions
  end
  
  ##
  # Decamelizes a string
  #
  # @param [required, String] the string to be decamelized
  # @return [String] the decamelized string
  def decamelize(string)
    string.gsub(/[A-Z]/) { |p| '_' + p.downcase }
  end
end