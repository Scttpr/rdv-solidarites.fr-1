# frozen_string_literal: true

describe Admin::Territories::AgentRolesController, type: :controller do
  describe "POST #update" do
    it "redirect to territorial agent edit on success" do
      territory = create(:territory)
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, allow_to_manage_teams: true, agent: agent)
      agent_role = create(:agent_role, agent: agent, level: "basic")
      sign_in agent

      post :update, params: { territory_id: territory.id, id: agent_role.id, agent_role: { level: "admin" } }
      expect(response).to redirect_to(edit_admin_territory_agent_path(territory, agent))
    end

    it "changes role" do
      territory = create(:territory)
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, allow_to_manage_teams: true, agent: agent)
      agent_role = create(:agent_role, agent: agent, level: "basic")
      sign_in agent

      expect do
        post :update, params: { territory_id: territory.id, id: agent_role.id, agent_role: { level: "admin" } }
      end.to change { agent_role.reload.level }.from(AgentRole::LEVEL_BASIC).to(AgentRole::LEVEL_ADMIN)
    end
  end

  describe "POST #create" do
    it "redirect to territorial agent edit on creation success" do
      territory = create(:territory)
      organisation = create(:organisation, territory: territory)
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, allow_to_manage_teams: true, agent: agent)
      other_agent = create(:agent, organisations: [])
      sign_in agent

      post :create, params: { territory_id: territory.id, agent_role: { level: "admin", agent_id: other_agent.id, organisation_id: organisation.id } }
      expect(response).to redirect_to(edit_admin_territory_agent_path(territory, other_agent))
    end
  end

  describe "DELETE #destroy" do
    let(:territory) { create(:territory) }
    let(:organisation) { create(:organisation) }

    before do
      # Il doit toujours y avoir au moins un agent responsable par territoire
      create(:agent, territories: [territory])

      # Il doit toujours y avoir au moins un agent Admin par organisation
      last_agent = create(:agent)
      create(:agent_territorial_access_right, territory: territory, agent: last_agent)
      create(:agent_role, organisation: organisation, agent: last_agent, level: "admin")
    end

    it "redirect to territorial_agent_edit on success if agent has another organisation" do
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, territory: territory, agent: agent)
      agent_role = create(:agent_role, organisation: organisation, agent: agent, level: "basic")
      organisation2 = create(:organisation, territory: territory)
      create(:agent_role, organisation: organisation2, agent: agent, level: "basic")

      sign_in agent

      delete :destroy, params: { territory_id: territory.id, id: agent_role.id }
      expect(response).to redirect_to(edit_admin_territory_agent_path(territory, agent))
    end

    it "redirect to territorial_agent_edit on success if it the last organisation" do
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, territory: territory, agent: agent)
      agent_role = create(:agent_role, organisation: organisation, agent: agent, level: "basic")

      sign_in agent

      delete :destroy, params: { territory_id: territory.id, id: agent_role.id }
      expect(response).to redirect_to(admin_territory_agents_path(territory))
    end

    it "destroy agent_role" do
      agent = create(:agent, role_in_territories: [territory])
      create(:agent_territorial_access_right, territory: territory, agent: agent)
      agent_role = create(:agent_role, organisation: organisation, agent: agent, level: "basic")

      sign_in agent

      expect do
        delete :destroy, params: { territory_id: territory.id, id: agent_role.id }
      end.to change(AgentRole, :count).from(2).to(1)
    end
  end
end
