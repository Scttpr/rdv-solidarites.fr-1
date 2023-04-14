# frozen_string_literal: true

class RdvBlueprint < Blueprinter::Base
  identifier :id

  fields :uuid, :status, :starts_at, :ends_at, :duration_in_min, :address, :context, :cancelled_at,
         :max_participants_count, :users_count, :name, :collectif, :created_by, :deleted_at

  association :organisation, blueprint: OrganisationBlueprint
  association :motif, blueprint: MotifBlueprint
  # DEPRECATED : Nous laissons l'association `:users` le temps que le 92, 26, 62, 64, et data-insertion mettent à jours leur système.
  association :users, blueprint: UserBlueprint
  association :rdvs_users, blueprint: RdvsUserBlueprint
  association :agents, blueprint: AgentBlueprint
  association :lieu, blueprint: LieuBlueprint

  field(:web_url) do |rdv|
    Rails.application.routes.url_helpers.admin_organisation_rdv_url(
      id: rdv.id,
      organisation_id: rdv.organisation.id,
      host: rdv.domain.dns_domain_name
    )
  end
end
