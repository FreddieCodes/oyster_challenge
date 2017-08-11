require "./lib/station.rb"
require "./lib/oystercard.rb"
require "./lib/journey.rb"
card = Oystercard.new
Bank = Station.new("Bank", 1)
Aldgate = Station.new("Aldgate", 2)
card.top_up 10
card.touch_in(Bank)
card.touch_in(Bank)
card.touch_out(Aldgate)
card.journeys
#asdf
