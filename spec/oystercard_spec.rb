require "oystercard"
require "station"
require 'journey'

describe Oystercard do
  let(:station) { double :station }
  let(:station1) { double :station1 }
  it "Default balance of zero" do
    new_card = Oystercard.new
    expect(new_card.balance).to eq 0
  end

  it "can be topped up" do
    subject.top_up 10
    expect(subject.balance).to eq 10
  end

  it "has a max balance of 90" do
    expect(subject.limit).to eq 90
  end

  it "can top up the balance" do
    expect { subject.top_up 1 }.to change { subject.balance }.by 1
  end

  it "raises error if insufficient funds" do
    expect { subject.touch_in(station) }.to raise_error "Insufficient funds"
  end

  it "raises error when topping up over limit" do
    subject.top_up 90
    expect { subject.top_up 10 } .to raise_error "Top-up limit of #{subject.limit} reached"
  end

  it "is in journey" do
    expect(subject).to respond_to(:in_journey?)
  end
  it "has a default status of not in use" do
    expect(subject.in_journey?).to eq "not in use"
  end

  it "can record touch in station" do
    subject.top_up(5)
    allow(station).to receive(:name).and_return("Paddington")
    subject.touch_in(station)
    expect(subject.journeys).to eq([{ in: "Paddington", out: "nil" }])
  end
  it "has an empty list of journeys by default" do
    expect(subject.journeys).to eq []
  end

  context "is topped up and has touched in" do
    before(:each) do
      subject.top_up(10)
      allow(station).to receive(:name) { "Paddington" }
      subject.touch_in(station)
    end

    it "can deduct the balance when touching out" do
      expect { subject.touch_out(station) }.to change { subject.balance }.by(-Oystercard::MIN_FARE)
    end

    it "changes its status to in use after touch in" do
      expect(subject.in_journey?).to eq "in use"
    end

  end

  context "One complete journey" do
    before(:each) do
      subject.top_up(10)
      station1 = double(Station)
      allow(station).to receive(:name) {"Bank"}
      allow(station1).to receive(:name) {"Aldgate"}
      subject.touch_in(station)
      subject.touch_out(station1)

    end

    it "will reduce the balance by a specified amount" do
      expect(subject.balance).to eq 9
    end

    it "changes its status to not in use after touch out" do
      expect(subject.in_journey?).to eq "not in use"
    end
    it "records journeys" do
      expect(subject.journeys).to eq([{ in: "Bank", out: "Aldgate" }])
    end
    it "creates one journey when touching in then out" do
      expect(subject.journeys.length).to eq 1
    end

  end

  context 'touching in' do
    before(:each) do
      subject.top_up(10)
      allow(station).to receive(:name) {"Bank"}
      allow(station1).to receive(:name) {"Aldgate"}
    end

    it 'checks if a journey is already in progress and charges pen fare if true' do
        subject.touch_in(station)
        expect {subject.touch_in(station)}.to change { subject.balance }.by(-Oystercard::PEN_FARE)
    end

    it 'starts a new journey when touching in' do
      expect(Journey).to receive(:new).with(station)
      subject.touch_in(station)
    end

    it "sets current journey to be an instance of Journey" do
      subject.touch_in(station)
      expect(subject.current_journey.is_a?(Journey)).to eq true
    end


  end

  context 'touching out' do
    before(:each) do
      subject.top_up(10)
      allow(station).to receive(:name) {"Bank"}
      allow(station1).to receive(:name) {"Aldgate"}
    end

# this is crap apaz - Kay says we need to not worry about the little bits in the test but worry
# about the actual outcomes we want to achieve - ie here we will worry about adding to the array if
# no journey instantiated and charging a penalty fare,
# or otherwise charging a normal fare and setting @current_journey to nil

    # it "if we haven't touched in, touch_out instantiates a new journey with no entry station" do
    #   expect(Journey).to receive(:new).with(no_args)
    #   subject.touch_out(station)
    # end

    # it "sets current journey to be an instance of Journey" do
    #   subject.touch_out(station)
    #   expect(subject.current_journey.is_a?(Journey)). to eq true
    # end

    # it 'calls end journey on the current journey' do
    #     # Possibly needs to be changed
    #     expect(subject.current_journey).to receive(:end_journey).with(station)
    #     subject.touch_out(station)
    # end

    # 3 tests removed as they were causing issues and were only testing the internal aspects
    # of the touch_in method rather than the actual desired outcome (following discussion with Kay)

    it "if new (penalty) journey instantiated, add it to journeys array" do
      expect { subject.touch_out(station) }.to change { subject.journeys.length }. by 1
    end

    it "adds a hash to the journey array (if not already added in touch in)" do
      subject.touch_out(station1)
      expect(subject.journeys.last.is_a?(Hash)).to eq true
    end

    it 'charges a fare on current journey' do
      subject.touch_in(station)
      expect {subject.touch_out(station1)}.to change { subject.balance }.by(-Oystercard::MIN_FARE)
    end

    it 'resets current journey' do
      subject.touch_out(station)
      expect(subject.current_journey).to eq nil
    end

  end

end
