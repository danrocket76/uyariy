class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # Guest user (not logged in)

    if user.admin?
      # Admins can do everything
      can :read, ActiveAdmin::Page, name: "Dashboard"
      can :manage, User
      can :manage, HearingAid
      can :manage, Recommendation
      can :manage, Appointment

      cannot :manage, Audiogram
      cannot :manage, Cart

    elsif user.audiologist?
      # Audiologists can READ everything, but cannot edit/create/delete

      can :read, User
      can :read, HearingAid

      can :manage, Appointment
      can :manage, Audiogram
      can :manage, Recommendation

    else
      # Patients can do nothing in the admin panel
    end
  end
end