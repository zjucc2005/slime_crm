# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    case user.role
      when 'su'      then su_ability
      when 'admin'   then admin_ability
      when 'pm'      then pm_ability
      when 'pa'      then pa_ability
      when 'finance' then finance_ability
      else nil
    end
  end

  def su_ability
    can :manage, :all
  end

  def admin_ability
    can :manage, User
    cannot :destroy, User
    can :manage, Candidate
    can :manage, Company
    can :manage, Contract
    can :manage, LocationDatum
    can :manage, Project
  end

  def pm_ability
    can_edit_my_account
    can :manage, Candidate
    can :read, LocationDatum
  end

  def pa_ability
    can_edit_my_account
    can :read, LocationDatum
  end

  def finance_ability
    can_edit_my_account
    can :read, LocationDatum
  end

  private
  def can_edit_my_account
    can [:my_account, :edit_my_account, :edit_my_password], User
  end

end
