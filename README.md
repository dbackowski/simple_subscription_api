# Simple Subscription API [![Build Status](https://travis-ci.org/dbackowski/simple_subscription_api.svg?branch=master)](https://travis-ci.org/dbackowski/simple_subscription_api) [![Coverage Status](https://coveralls.io/repos/github/dbackowski/simple_subscription_api/badge.svg?branch=master)](https://coveralls.io/github/dbackowski/simple_subscription_api?branch=master)

## Billing Gateway API

Billing Gateway API is stub on URL "http://fake-billing-gateway.com" with webmock gem as follows:

* all Visa cards returns response status = 200 and paid = true

```ruby
rails c
2.5.1 :001 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=4552021430083752303&amount=100')
=> #<HTTParty::Response:0x7f8c10366b10 parsed_response="{\"id\":\"dc6900fddc91f3fe\",\"paid\":true,\"failure_message\":null}", @response=#<Net::HTTPOK 200  readbody=true>, @headers={}>
```

* all Mastercard cards first request throws Net::OpenTimeout exception, second one and next returns status = 200 and paid = true

```ruby
rails c
2.5.1 :001 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=2231644170212817&amount=100')
Traceback (most recent call last):
        1: from (irb):9
Net::OpenTimeout (execution expired)
mastercard
2.5.1 :002 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=2231644170212817&amount=100')
 => #<HTTParty::Response:0x2f7ecf0 parsed_response="{\"id\":\"7c9525cea676c332\",\"paid\":true,\"failure_message\":null}", @response=#<Net::HTTPOK 200  readbody=true>, @headers={}>
```

* all American Express cards first request throws Net::HTTPServiceUnavailable, second one and next returns status = 200 and paid = true

```ruby
2.5.1 :001 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=371173241821608&amount=100')
 => #<HTTParty::Response:0x472d630 parsed_response="Interval Server Error", @response=#<Net::HTTPServiceUnavailable 503  readbody=true>, @headers={}>
2.5.1 :002 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=371173241821608&amount=100')
 => #<HTTParty::Response:0x7f8c1017e2f8 parsed_response="{\"id\":\"39c8279b11798f7d\",\"paid\":true,\"failure_message\":null}", @response=#<Net::HTTPOK 200  readbody=true>, @headers={}>
```

* all Maestro cards returns status = 200 and paid = false

```ruby
2.5.1 :001 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=62742036440476668&amount=100')
 => #<HTTParty::Response:0x3a56c40 parsed_response="{\"id\":\"20699734f2befe4f\",\"paid\":false,\"failure_message\":\"insufficient_funds\"}", @response=#<Net::HTTPOK 200  readbody=true>, @headers={}>
```

* all Discover cards throws timeout exception

```
2.5.1 :001 > HTTParty.get('http://fake-billing-gateway.com/?credit_card_number=6441422827428017459&amount=100')
Traceback (most recent call last):
        1: from (irb):1
Net::OpenTimeout (execution expired)
```

## Subscriptions API

### Listing subscriptions

```
curl -H "Content-Type: application/json" -X GET http://localhost:3000/api/v1/subscriptions
[{"id":1,"credit_card_number":"4640814081369","name":"Dwayne Kris","address":"883 Glover Shores","country":"Reunion","next_billing_date":"2018-05-30","created_at":"2018-04-30T08:14:41.323Z","updated_at":"2018-04-30T08:14:41.323Z"},{"id":2,"credit_card_number":"2224430203084012","name":"Xiao Crist","address":"1867 Bruen Isle","country":"Tokelau","next_billing_date":"2018-05-30","created_at":"2018-04-30T08:14:52.603Z","updated_at":"2018-04-30T08:14:52.603Z"},{"id":3,"credit_card_number":"378380400053328","name":"Xiao Crist","address":"1867 Bruen Isle","country":"Tokelau","next_billing_date":"2018-05-30","created_at":"2018-04-30T08:14:57.561Z","updated_at":"2018-04-30T08:14:57.561Z"}]
```

### Creating subscriptions

* example with Visa card

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"4640814081369","name":"Dwayne Kris","address": "883 Glover Shores","country":"Reunion"}}' http://localhost:3000/api/v1/subscriptions
{"id":1,"credit_card_number":"4640814081369","name":"Dwayne Kris","address":"883 Glover Shores","country":"Reunion","next_billing_date":"2018-05-30","created_at":"2018-04-30T07:59:28.321Z","updated_at":"2018-04-30T07:59:28.321Z"}
```

* example with MasterCard card

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"2224430203084012","name":"Xiao Crist","address": "1867 Bruen Isle","country":"Tokelau"}}' http://localhost:3000/api/v1/subscriptions
{"id":2,"credit_card_number":"2224430203084012","name":"Xiao Crist","address":"1867 Bruen Isle","country":"Tokelau","next_billing_date":"2018-05-30","created_at":"2018-04-30T08:00:13.309Z","updated_at":"2018-04-30T08:00:13.309Z"}
```

* example with Amerrican Express card

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"378380400053328","name":"Xiao Crist","address": "1867 Bruen Isle","country":"Tokelau"}}' http://localhost:3000/api/v1/subscriptions
{"id":3,"credit_card_number":"378380400053328","name":"Xiao Crist","address":"1867 Bruen Isle","country":"Tokelau","next_billing_date":"2018-05-30","created_at":"2018-04-30T08:00:55.751Z","updated_at":"2018-04-30T08:00:55.751Z"}
```

* example with Maestro card

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"6167883645588646","name":"Craig Brown","address": "81750 Johnston Crescent","country":"New Zealand"}}' http://localhost:3000/api/v1/subscriptions
{"errors":"insufficient_funds"}
```

* example with invalid credit card number

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"4640814081361","name":"Dwayne Kris","address": "883 Glover Shores","country":"Reunion"}}' http://localhost:3000/api/v1/subscriptions
{"errors":["Credit card number is invalid"]}
```

* example with empty address

```
curl -H "Content-Type: application/json" -X POST -d '{"data":{"credit_card_number":"4640814081369","name":"Dwayne Kris","address": "","country":"Reunion"}}' http://localhost:3000/api/v1/subscriptions
{"errors":["Address can't be blank"]}
```