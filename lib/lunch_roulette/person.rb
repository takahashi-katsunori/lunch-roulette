class LunchRoulette

  class Person
    # attr_accessor :name, :lunchable, :previous_lunches, :features, :team, :specialty, :user_id, :start_date, :table, :email
    attr_accessor :name, :email, :start_date, :team, :manager, :lunchable_default, :lunchable_survey_response, :lunchable_survey_date, :previous_lunches
    def initialize(name:, email:, start_date:, team:, manager: nil, lunchable_default: nil, lunchable_survey_response: nil, lunchable_survey_date: nil, previous_lunches: nil)
      @name = name
      @email = email
      @start_date = start_date
      @team = team
      @manager = manager
      @lunchable_default = lunchable_default
      @lunchable_survey_response = lunchable_survey_response
      @lunchable_survey_date = lunchable_survey_date
      @previous_lunches = previous_lunches
    end

    def lunchable?
      if lunchable_survey_date && (Date.today - lunchable_survey_date).to_i < 30
        lunchable_survey_response == 'Yep'
      else
        lunchable_default != 'FALSE'
      end
    end

    def days_here
      (Date.today - @start_date).to_i
    end

    def team_value
      config.team_mappings[@team].to_i
    end

    def add_lunch(lunch)
      self.class.new(
        name: name,
        email: email,
        start_date: start_date,
        team: team,
        manager: manager,
        lunchable_default: lunchable_default,
        lunchable_survey_response: lunchable_survey_response,
        lunchable_survey_date: lunchable_survey_date,
        previous_lunches: previous_lunches + Array(lunch)
      )
    end

    # def lunches(new_lunch: nil)
    #   [email, previous_lunches + Array(new_lunch)]
    # end


    # def initialize(hash)
    #   # @features = {}
    #   @lunchable = %w(true TRUE).include? hash['lunchable']
    #   @team = hash['team']
    #   @user_id = hash['user_id']
    #   @email = hash['email']
    #   @specialty = hash['specialty']
    #   @start_date = hash['start_date']
    #   @features['days_here'] = (Date.today - Date.strptime(@start_date, '%m/%d/%Y')).to_i
    #   @features['team'] = config.team_mappings[@team].to_i
    #   # @features['specialty'] = config.specialty_mappings[@specialty].to_i
    #   # @features['table'] = @table = hash['table'].to_i
    #   @name = hash['name']
    #   @previous_lunches = []
    #   if hash['previous_lunches']
    #     @previous_lunches = hash['previous_lunches'].split(',').map{|i| i.to_i }
    #     config.maxes['lunch_id'] = @previous_lunches.max if @previous_lunches && (@previous_lunches.max > config.maxes['lunch_id'].to_i)
    #     # Generate previous lunches to person mappings:
    #     @previous_lunches.map do |previous_lunch|
    #       config.previous_lunches[previous_lunch] ||= LunchGroup.new
    #       config.previous_lunches[previous_lunch].people = [config.previous_lunches[previous_lunch].people, self].flatten
    #     end
    #   end
    # end

    # def inspect
    #   s = @name
    #   if @specialty
    #     s += " (#{@team} - #{@specialty}"
    #   else
    #     s += " (#{@team}"
    #   end
    #   s += ", Table #{@table})"
    #   s
    # end

    def config
      LunchRoulette::Config
    end

  end
end
