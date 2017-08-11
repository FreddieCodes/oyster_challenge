# require_relative "./station.rb"
require 'station'
require 'journey'


class Oystercard
  DEFAULT_BALANCE = 0
  CARD_LIMIT = 90
  MIN_FARE = 1
  PEN_FARE = 6 # touchin * 2   ... touchout *2

  attr_reader :balance, :limit, :current_journey
  attr_accessor :entry_station, :journeys

  def initialize(balance = DEFAULT_BALANCE)
    @balance = balance
    @limit = CARD_LIMIT
    @journeys = []
    @current_journey = nil
  end

  def top_up(amount)
    raise "Top-up limit of #{@limit} reached" if over_limit?(amount)
    @balance += amount
    "Your balance is now: £#{@balance}"
  end

  def touch_in(station)
    deduct(@current_journey.fare) if !@current_journey.nil?
    @current_journey = Journey.new(station)
    raise 'Insufficient funds' if insufficient_funds?
    @journeys << { in: station.name, out: 'nil' }
    # @journeys << {in: "#{station.name}(#{station.zone})", out: "nil"}
  end

  def touch_out(station)
    if @current_journey.nil?
      @current_journey = Journey.new
      p Journey.new
      @journeys << { in: @current_journey.entry_station, out: station }
    end
    p "One below"
    p @current_journey
    @current_journey.end_journey(station)
    @journeys.last[:out] = station.name
    deduct(@current_journey.fare)
    @current_journey = nil
    # @journeys[@trip_no-1][:out] = "#{station.name}(#{station.zone})"
  end

  def in_journey?
    return 'not in use' if @journeys == []
    return 'in use' if @journeys.last[:out] == 'nil'
    return 'not in use' unless @journeys.last[:out].nil?
  end

  # def station_details
  #   "#{station.name} (#{station.zone})"
  # end

  private

  def over_limit?(amount)
    (amount + @balance) > @limit
  end

  def insufficient_funds?
    @balance < MIN_FARE
  end

  def deduct(amount)
    @balance -= amount
  end
end
