billwise4r
==========

Gem for working with the Billwise SOAP/XML API.

Examples
--------

	require 'billwise4r'
	billwise = Billwise.new({ :companyCd  => 123,
	                          :username   => 'username',
	                          :password   => 'password',
	                          :wsdl_url   => 'https://cwa021.connect4billing.com/axis2/services/ConnectSmService?wsdl',
	                          :endpoint   => 'https://cwa021.connect4billing.com/axis2/services/ConnectSmService.ConnectSmServiceHttpSoap12Endpoint/',
	                          :namespace  => 'http://connectsm.ws.bwse.com/xsd',
	                          :log        => true,
	                          :log_evel   => :debug })
	customer = billwise.find_customer(:customerCd => '000987')
	services = billwise.find_services({ :customerCd => '000123',
	                                    :serviceId  => 'A000000000000456',
	                                    :status     => 'A' })

Copyright
---------

Copyright (c) 2010, 2011 Jason Goecke. See LICENSE.txt for further details.

