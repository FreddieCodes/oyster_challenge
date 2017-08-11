require 'journey'

describe Journey do
  let(:journey) { described_class.new("Victoria") }
  let(:station) { double :station }
  let(:station1) { double :station1 }

 context '#initialize' do

   it "takes a starting station" do
      expect(journey.entry_station).to eq "Victoria"
    end

   it "initializes with 'didn't tap in' if no entry station" do
      expect(subject.entry_station).to eq "Has not tapped in"
    end

   it "initializes with an exit station of nil" do
      expect(journey.end_station).to eq nil
    end

 end

 context 'end_journey' do

  it "take an end end station" do
    journey.end_journey(station)
    expect(journey.end_station).to eq station
  end

 end
end
