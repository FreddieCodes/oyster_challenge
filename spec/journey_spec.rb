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

  context 'charges a relevant fare' do

    it "standard fare if touched in and out" do
      journey.end_journey(station1)
      expect(journey.fare).to eq Journey::MIN_FARE
    end

    it "penalty fare if touched in but not out" do
      expect(journey.fare).to eq Journey::PEN_FARE
    end

    it "penalty fare if touched out but not in" do
      subject.end_journey(station1)
      expect(subject.fare).to eq Journey::PEN_FARE
    end

  end

  context ''

end
