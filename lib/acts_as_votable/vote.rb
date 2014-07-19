require 'acts_as_votable/helpers/words'

module ActsAsVotable
  class Vote < ::ActiveRecord::Base
    include PublicActivity::Model

    include Helpers::Words

    if defined?(ProtectedAttributes) || ::ActiveRecord::VERSION::MAJOR < 4
      attr_accessible :votable_id, :votable_type,
        :voter_id, :voter_type,
        :votable, :voter,
        :vote_flag, :vote_scope
    end

    belongs_to :votable, :polymorphic => true
    belongs_to :voter, :polymorphic => true

    scope :up, lambda{ where(:vote_flag => true) }
    scope :down, lambda{ where(:vote_flag => false) }
    scope :for_type, lambda{ |klass| where(:votable_type => klass) }
    scope :by_type,  lambda{ |klass| where(:voter_type => klass) }

    validates_presence_of :votable_id
    validates_presence_of :voter_id
    
    before_destroy :find_and_destroy_activity
    
    private
      def find_and_destroy_activity
        activity = PublicActivity::Activity.find_by_trackable_id(self.id)
        if activity.present?
          activity.destroy
        end
      end

  end

end

