## $Id$

## Copyright (C) 2004 NABEYA Kenichi (aka nanami@2ch)
## Copyright (C) 2007-2008 Daigo Moriwaki (daigo at debian dot org)
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

module ShogiServer # for a namespace

# Abstract class to caclulate thinking time.
#
class TimeClock

  def TimeClock.factory(least_time_per_move, game_name)
    total_time_str = nil
    byoyomi_str = nil
    if (game_name =~ /-(\d+)-(\d+)$/)
      total_time_str = $1
      byoyomi_str    = $2
    end
    total_time = total_time_str.to_i
    byoyomi    = byoyomi_str.to_i
 
    if (byoyomi_str == "060")
      @time_clock = StopWatchClock.new(least_time_per_move, total_time, byoyomi)
    else
      @time_clock = ChessClock.new(least_time_per_move, total_time, byoyomi)
    end
  end

  def initialize(least_time_per_move, total_time, byoyomi)
    @least_time_per_move = least_time_per_move
    @total_time = total_time
    @byoyomi     = byoyomi
  end

  # Returns thinking time duration
  #
  def time_duration(start_time, end_time)
    # implement this
    return 9999999
  end

  # If thinking time runs out, returns true; false otherwise.
  #
  def timeout?(player, start_time, end_time)
    # implement this
    return true
  end

  # Updates a player's remaining time and returns thinking time.
  #
  def process_time(player, start_time, end_time)
    t = time_duration(start_time, end_time)
    
    player.mytime -= t
    if (player.mytime < 0)
      player.mytime = 0
    end

    return t
  end
end

# Calculates thinking time with chess clock.
#
class ChessClock < TimeClock
  def initialize(least_time_per_move, total_time, byoyomi)
    super
  end

  def time_duration(start_time, end_time)
    return [(end_time - start_time).floor, @least_time_per_move].max
  end

  def timeout?(player, start_time, end_time)
    t = time_duration(start_time, end_time)

    if ((player.mytime - t <= -@byoyomi) && 
        ((@total_time > 0) || (@byoyomi > 0)))
      return true
    else
      return false
    end
  end

  def to_s
    return "ChessClock: LeastTimePerMove %d; TotalTime %d; Byoyomi %d" % [@least_time_per_move, @total_time, @byoyomi]
  end
end

class StopWatchClock < TimeClock
  def initialize(least_time_per_move, total_time, byoyomi)
    super
  end

  def time_duration(start_time, end_time)
    t = [(end_time - start_time).floor, @least_time_per_move].max
    return (t / @byoyomi) * @byoyomi
  end

  def timeout?(player, start_time, end_time)
    t = time_duration(start_time, end_time)

    if (player.mytime <= t)
      return true
    else
      return false
    end
  end

  def to_s
    return "StopWatchClock: LeastTimePerMove %d; TotalTime %d; Byoyomi %d" % [@least_time_per_move, @total_time, @byoyomi]
  end
end

end
