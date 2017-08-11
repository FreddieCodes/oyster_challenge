class Journey
  attr_reader :entry_station, :end_station

  def initialize(entry_station = "Has not tapped in")
    @entry_station = entry_station
    @end_station = nil
  end

  def end_journey(station)
    @end_station = station
  end
end
