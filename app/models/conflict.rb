class Conflict < ApplicationRecord
  belongs_to :person

  ONCE = 'O'
  WEEKLY = 'W'

  validates :frequency, presence: true
  validates :frequency, inclusion: [ONCE, WEEKLY]

  def start=(str)
    super(DateTime.parse(str))
  end

  def end=(str)
    super(DateTime.parse(str))
  end

  def once?
    frequency == ONCE
  end

  def weekly?
    frequency == WEEKLY
  end

  def fits?(fit_start, fit_end)
    if weekly?
      # only consider times mod one week
      mod_self_start = self.start.to_i % 1.week
      mod_self_end = self.end.to_i % 1.week
      mod_fit_start = fit_start.to_i % 1.week
      mod_fit_end = fit_end.to_i % 1.week
      # Sorry for this horrible if/then soup... It's the only way I can
      # think of to deal with the fact that sometimes the end time will be
      # "before" the start time modulo one week (i.e. if an interval starts
      # on a Sunday and ends on a Monday).
      if mod_self_end < mod_self_start # self end wraps around
        mod_self_end < mod_fit_start and mod_fit_start < mod_fit_end \
          and mod_fit_end < mod_self_start
      elsif mod_fit_end < mod_fit_start # fit end wraps around
        mod_fit_end < mod_self_start and mod_self_start < mod_self_end \
          and mod_self_end < mod_fit_start
      else # no wrapping
        mod_fit_end < mod_self_start or mod_self_end < mod_fit_start
      end
    else
      fit_end < self.start or self.end < fit_start
    end
  end
end
