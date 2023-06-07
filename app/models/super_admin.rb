# frozen_string_literal: true

class SuperAdmin < ApplicationRecord
  # Mixins
  include DeviseInvitable::Inviter

  devise :authenticatable

  ## -

  def full_name
    "l'équipe technique de RDV-Solidarités"
  end
end
