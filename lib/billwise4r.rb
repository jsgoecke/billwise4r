class Billwise
  require "billwise4r/version"
  require 'savon'
  require 'multi_xml'

  ##
  # Instantiates a new Billwise class
  #
  def initialize(params={})
    # Make sure all params we need are here or raise an error
    check_initialization_params(params)

    @companyCd        =  params[:companyCd]
    log               =  params[:log]           || false
    log_level         =  params[:log_level]     || :info
    @httpi_log        =  params[:httpi_log]     || false
    @ssl_verify_mode  =  params[:verify_mode]   || "peer"
    @read_timeout     =  params[:read_timeout]  || 300

    Savon.configure do |config|
      config.log            =  log
      config.log_level      =  log_level
      config.env_namespace  =  :soap
    end

    @soap_endpoint   =  URI.parse params[:endpoint] || 'https://cwa021.connect4billing.com:8443/axis2/services/ConnectSmService.ConnectSmServiceHttpSoap12Endpoint/'
    @soap_namespace  =  params[:namespace]          || 'http://connectsm.ws.bwse.com/xsd'
    @soap_version    =  2

    # Build our SOAP driver
    @soap_driver = Savon::Client.new do
      wsse.credentials params[:username] , params[:password]
      wsdl.document =  'https://cwa021.connect4billing.com:8443/axis2/services/ConnectSmService?wsdl'
    end

    @soap_driver.http.read_timeout                =  @read_timeout
    @soap_driver.http.auth.ssl.verify_mode        =  @ssl_verify_mode.to_sym                                     # or one of [:peer, :fail_if_no_peer_cert, :client_once]
    @soap_driver.http.auth.ssl.cert_key_file      =  params[:cert_key_file]      if  params[:cert_key_file]      # the private key file to use
    @soap_driver.http.auth.ssl.cert_key_password  =  params[:cert_key_password]  if  params[:cert_key_password]  # the key file's password
    @soap_driver.http.auth.ssl.cert_file          =  params[:cert_file]          if  params[:cert_file]          # the certificate file to use
    @soap_driver.http.auth.ssl.ca_cert_file       =  params[:ca_cert_file]       if  params[:ca_cert_file]       # the ca certificate file to use

    @tag_order                                    =  tag_order

    MultiXml.parser                               =  :nokogiri
  end

  ##
  # A catch all for the methods defined by the WSDL
  # refer to the Billwise API documentation for details
  #
  # @return [Hash] the Billwise response
  def method_missing(method, params)
    begin
      HTTPI.log = @httpi_log
      response = @soap_driver.request :wsdl, method do |soap, wsse|
        soap.version                   =  @soap_version
        soap.endpoint                  =  @soap_endpoint
        soap.namespaces                =  Hash.new
        soap.namespaces["xmlns:soap"]  =  "http://www.w3.org/2003/05/soap-envelope"
        soap.namespaces["xmlns:ins0"]  =  @soap_namespace

        fields = { :companyCd => @companyCd }.merge!(params)

        fields = order_hash(:method=>method, :fields=>fields)

        soap.body = fields

      end
      response.to_hash["#{method}_response".to_sym][:return]
    rescue Savon::SOAP::Fault => fault
      response = {'error' => 'soapfault', 'message' => fault}
    end
  end

  private

  ##
  # Order has correctly since billwise requires soap parameters be in correct order.
  # Savon provides this functionality thru gyoku but it doesnt seem to be working in 1.9.
  # This being the case I decided to roll my own
  def order_hash(opts={})
    ordered_hash={}
    @tag_order[opts[:method].to_sym].each do |o|
      ordered_hash.merge!(o.to_sym=>opts[:fields][o.to_sym])
    end
    ordered_hash
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
    MultiXml.parse(@soap_driver.wsdl.xml)['definitions']['types']['schema'][3]['element'].each do |action|
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
  # Checks that the required params have been provided, or rasies an error
  def check_initialization_params(params={})
    raise ArgumentError, "You must provide Billwise connection parameters." if params.length == 0
    %w(companyCd username password).each { |param| raise ArgumentError, "You must provide a valid #{param}." if params[param.to_sym].nil? }
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
