require "oystercard"
require "station"

describe Oystercard do
  let(:station) { double :station }
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
    # message
    expect { subject.top_up 10 } .to raise_error "Top-up limit of #{subject.limit} reached"
  end

  it "is in journey" do
    expect(subject).to respond_to(:in_journey?)
  end
  it "has a default status of not in use" do
    expect(subject.in_journey?).to eq "not in use"
  end
  let(:station) { double :station }
  it "can record touch in station" do
    subject.top_up(5)
    # station = Station.new("Paddington")
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
end
