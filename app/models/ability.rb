# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    cannot :manage, :all
    basic_actions
    if !user.nil?
      can :manage, User , id: user.id
      
      if user.role_type == "Reader"
        can [:borrow, :take_reserved, :return_it], Copy
        can :manage, Reader , id: user.role.id
      elsif user.role_type == "Librarian"
        can :manage, [Book, Copy, Ticket]
        can :manage, User
        can :manage, :librarian # for non-restful controller
        can :manage, :signup
      end
    end
  end
private
  def basic_actions
    can :read, [Book, Copy, User]
    can [:read_book, :put_it_back], Copy
  end
end
