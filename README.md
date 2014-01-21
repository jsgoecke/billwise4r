billwise4r
==========
[![Build Status](https://drone.io/github.com/jsgoecke/billwise4r/status.png)](https://drone.io/github.com/jsgoecke/billwise4r/latest)

Gem for working with the Billwise SOAP/XML API. Ruby 1.9.x +

Examples
--------
```ruby
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

```
Optional Configution Parameters
---------

    SSL verify_mode    		    -  [:peer, :fail_if_no_peer_cert, :client_once]
    cert_key_file				-  the private key file to use
    cert_key_password       	-  the key file's password
    cert_file 					-  the certificate file to use
    ca_cert_file				-  the ca certificate file to use

Authors
-------

Jason Goecke ([@jsgoecke](http://twitter.com/jsgoecke)) & John Dyer ([@thedyers](http://twitter.com/thedyers))

Copyright
---------

Copyright (c) 2010-2014 Jason Goecke. See LICENSE.txt for further details.

