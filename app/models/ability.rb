class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      # Admins have access to everything except audiograms and can edit/create/update or delete
      can :read, ActiveAdmin::Page, name: "Dashboard"
      can :manage, User
      can :manage, HearingAid
      can :manage, Recommendation
      can :manage, Appointment

      cannot :manage, Audiogram
      cannot :manage, Cart

    elsif user.audiologist?
      # Audiologists can READ everything except the dashboard and cart, but they cannot edit/create or delete

      can :read, User
      can :read, HearingAid

      can :manage, Appointment
      can :manage, Audiogram
      can :manage, Recommendation

    else
    end
  end
end