require 'webmock'
include WebMock::API

WebMock.enable!

# stub fake billing gateway call (for all visa cards, reponse status: 200, paid: true)
uri_template = Addressable::Template.new "http://fake-billing-gateway.com/{?credit_card_number}{&amount}"
stub_request(:any, uri_template).with do |request|
  CreditCardValidations::Detector.new(request.uri.query_values['credit_card_number']).visa?
end.to_return(
  status: 200,
  body: {
    id: SecureRandom.hex(8),
    paid: true,
    failure_message: nil
  }.to_json
)

# stub fake billing gateway call (for all mastercard cards first raise timeout then reponse status: 200, paid: true)
uri_template = Addressable::Template.new "http://fake-billing-gateway.com/{?credit_card_number}{&amount}"
stub_request(:any, uri_template).with do |request|
  CreditCardValidations::Detector.new(request.uri.query_values['credit_card_number']).mastercard?
end.to_timeout.then.to_return(
  status: 200,
  body: {
    id: SecureRandom.hex(8),
    paid: true,
    failure_message: nil
  }.to_json
)

# stub fake billing gateway call (for all american expres cards first raise exception then reponse status: 200, paid: true)
uri_template = Addressable::Template.new "http://fake-billing-gateway.com/{?credit_card_number}{&amount}"
stub_request(:any, uri_template).with do |request|
  CreditCardValidations::Detector.new(request.uri.query_values['credit_card_number']).amex?
end.to_return(status: 503, body: 'Interval Server Error').then.to_return(
  status: 200,
  body: {
    id: SecureRandom.hex(8),
    paid: true,
    failure_message: nil
  }.to_json
)

# stub fake billing gateway call (for all maestro cards, reponse status: 200, paid: false)
uri_template = Addressable::Template.new "http://fake-billing-gateway.com/{?credit_card_number}{&amount}"
stub_request(:any, uri_template).with do |request|
  CreditCardValidations::Detector.new(request.uri.query_values['credit_card_number']).maestro?
end.to_return(
  status: 200,
  body: {
    id: SecureRandom.hex(8),
    paid: false,
    failure_message: 'insufficient_funds'
  }.to_json
)

# stub fake billing gateway call (for all other cards, reponse status: 200, paid: false)
uri_template = Addressable::Template.new "http://fake-billing-gateway.com/{?credit_card_number}{&amount}"
stub_request(:any, uri_template).with do |request|
  detector = CreditCardValidations::Detector.new(request.uri.query_values['credit_card_number'])
  !detector.valid? || (!detector.visa? && !detector.mastercard? && !detector.amex? && !detector.maestro?)
end.to_return(
  status: 200,
  body: {
    id: SecureRandom.hex(8),
    paid: false,
    failure_message: 'insufficient_funds'
  }.to_json
)
