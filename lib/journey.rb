class Journey
  MIN_FARE = 1
  PEN_FARE = 6 # touchin * 2   ... touchout *2
  attr_reader :entry_station, :end_station

  def initialize(entry_station = "Has not tapped in")
    @entry_station = entry_station
    @end_station = nil
  end

  def end_journey(station)
    @end_station = station
  end

  def fare
    if @entry_station!= "Has not tapped in" && @end_station
      MIN_FARE
    else
      PEN_FARE
    end
  end

end
