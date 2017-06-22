class LunchRoulette

  class Lunch
    attr_accessor :set_id, :group_id
    def initialize(set_id:, group_id:)
      @set_id = set_id
      @group_id = group_id
    end

    def equals(other_lunch)
      set_id == other_lunch.set_id && group_id = other_lunch.group_id
    end

    def to_str
      [set_id, group_id].join('-')
    end
  end

  class LunchGroup

    attr_accessor :people, :lunch

    def initialize(people:, lunch:)
      @people = people
      @lunch = lunch
    end

    def config
      LunchRoulette::Config
    end

    def inspect
      people.map(&:inspect).join(", ")
    end

    def emails
      people.map(&:email).join(", ")
    end

    def valid?
      # score <= config.max_group_score &&
        manager_score <= 1
    end

    def score
      config.tenure_weight * tenure_score +
        config.team_weight * team_score +
        config.manager_weight * manager_score + 
        config.colleague_weight * colleague_score + 
        config.previous_lunches_weight * previous_lunches_score
    end

    def tenure_score
      100.0 / (1 + people.map(&:days_here).standard_deviation)
    end

    def team_score
      10.0 / (1 + people.map(&:team_value).standard_deviation)
    end
    
    def manager_score
      names = people.map(&:name)
      managers = people.map(&:manager)
      overlap = names & managers
      managers.count{|m| overlap.include?(m)}
    end

    def colleague_score
      managers = people.map(&:manager)
      managers.uniq.reduce(0) do |sum, manager|
        count = managers.count(manager)
        sum + (count - 1) ** 2
      end
    end

    def previous_lunches_score
      previous_lunches = people.flat_map(&:previous_lunches)
      previous_lunches.uniq.reduce(0) do |sum, prev_lunch|
        count = previous_lunches.count{|p| prev_lunch.equals(p)}
        sum + (count - 1) ** 2 * previous_lunch_decay(prev_lunch.set_id)
      end
    end

    def previous_lunch_decay(prev_set_id)
      coeff = -1.0 * Math.log(2) / (config.previous_lunches_half_life)
      Math.exp(coeff * (lunch.set_id - prev_set_id))
    end

    def print_scores
      puts "Group #{lunch.group_id}: score #{score} (tenure #{tenure_score}, teams #{team_score}, managers #{manager_score}, colleagues #{colleague_score}, previous_lunches #{previous_lunches_score})"
    end
    # def calculate_group_score
    #   # Scores are normalized to the maximum value of all staff, then we get the standard deviation
    #   # This is later averaged across all the features of the group, so that groups with higher variance
    #   # will have a higher average. The averages of each group in a set is then summed to determine the
    #   # overall variance of the set.
    #   h = features.map do |feature|
    #     s = @people.map do |person|
    #       person.features[feature] / config.maxes[feature].to_f
    #     end.standard_deviation
    #     [feature, s * config.weights[feature]]
    #   end
    #   @scores = Hash[*h.flatten]
    # end

    # def calculate_previous_lunches_factor
    #   factor = 1.0
    #   max_lunch_id = @config.maxes['lunch_id'].to_i
    #   return factor if @previous_lunches.nil?
    #   @previous_lunches.each do |threshold, previous_lunches_above_threshold|
    #     previous_lunches_above_threshold.each do |previous_lunch_id|
    #       time = (max_lunch_id - previous_lunch_id).to_f
    #       factor *= (1.0 - Math.exp(-1.0 * (time / config.time_decay_constant) ** 2))
    #     end
    #   end
    #   factor
    # end

    # def features
    #   config.weights.keys
    # end

    # # Find the group's previous lunches if there are any.
    # def find_previous_lunches
    #   @people.each do |person|
    #     if person.previous_lunches
    #       person.previous_lunches.map do |previous_lunch|
    #         @config.match_thresholds.map do |match_threshold|
    #           if ((@config.previous_lunches[previous_lunch].people - [person]) & @people).size >= (match_threshold - 1)
    #             @previous_lunches[match_threshold] ||= Set.new
    #             @previous_lunches[match_threshold] << previous_lunch
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    # def calculate_boss_factor
    #   @people.map(&:name).combination(2).to_a.reduce(0) do |sum, pair|
    #     distance = 0
    #     if compute_boss_distance(pair[0], pair[1]) == 1
    #       distance = 1
    #     end
    #     sum + distance
    #   end
    # end

    # def compute_boss_distance(person1, person2)
    #   @children_hash ||= get_children(config.hierarchy)
    #   distance = compute_descendent_distance(person1, person2, @children_hash)
    #   distance > 0 ? distance : compute_descendent_distance(person2, person1, @children_hash)
    # end

    # def compute_descendent_distance(elder, younger, children_hash, depth = 1)
    #   elder_children = children_hash[elder]
    #   if elder_children.nil?
    #     return 0
    #   end
    #   if elder_children.include? younger
    #     return depth
    #   end
    #   distance = 0
    #   elder_children.each do |child|
    #     distance = compute_descendent_distance(child, younger, children_hash, depth + 1)
    #     return distance if distance > 0
    #   end
    #   distance
    # end

    # def get_children(hierarchy, flat_hash = {})
    #   hierarchy.each do |person, children|
    #     flat_hash[person] = (children.nil? ? nil : children.keys)
    #     flat_hash.merge!(get_children(children, flat_hash)) unless children.nil?
    #   end
    #   flat_hash
    # end

    # def calculate_teammate_factor
    #   @people.map(&:name).combination(2).to_a.reduce(0) do |sum, pair|
    #     siblings = 0
    #     if are_siblings?(pair[0], pair[1])
    #       siblings = 1
    #     end
    #     sum + siblings
    #   end
    # end

    # def are_siblings?(person1, person2)
    #   @parents_hash ||= get_parents(config.hierarchy)
    #   @parents_hash[person1] == @parents_hash[person2]
    # end

    # def get_parents(hierarchy, flat_hash = {})
    #   hierarchy.each do |parent, children|
    #     unless children.nil?
    #       children.keys.each {|child| flat_hash[child] = parent}
    #       flat_hash.merge!(get_parents(children, flat_hash))
    #     end
    #   end
    #   flat_hash
    # end

  end
end

