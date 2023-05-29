# frozen_string_literal: true

describe Agent, type: :model do
  describe "#destroy" do
    context "with remaining organisations attached" do
      let(:organisation) { create(:organisation) }
      let(:agent) { create(:agent, basic_role_in_organisations: [organisation]) }

      it "aborts destruction" do
        expect(agent.destroy).to eq(false)
        agent.reload # does not crash, so agent was not desrtroyed
      end
    end

    context "without organisations" do
      let!(:agent) { create(:agent) }

      it "destroys the agent" do
        agent.destroy
        expect { agent.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#available_referents_for" do
    it "returns empty array without agents" do
      user = build(:user, referent_agents: [])
      expect(described_class.available_referents_for(user)).to eq([])
    end

    it "returns agent that not already referents array without agents" do
      agent = create(:agent)
      already_referent = create(:agent)
      user = create(:user, referent_agents: [already_referent])
      expect(described_class.available_referents_for(user)).to eq([agent])
    end
  end

  describe "#update_unknown_past_rdv_count!" do
    it "update with 0 if no past RDV" do
      agent = create(:agent)
      agent.update_unknown_past_rdv_count!
      expect(agent.reload.unknown_past_rdv_count).to eq(0)
    end

    it "update with 1 with one past RDV" do
      now = Time.zone.parse("20211123 10:45")
      travel_to(now)
      agent = create(:agent)
      create(:rdv, starts_at: now - 1.day, status: :unknown, agents: [agent])
      agent.update_unknown_past_rdv_count!
      expect(agent.reload.unknown_past_rdv_count).to eq(1)
    end
  end

  describe "#to_s" do
    it "return Validay Martine" do
      agent = build(:agent, last_name: "Validay", first_name: "Martine")
      expect(agent.to_s).to eq("Martine Validay")
    end
  end

  describe "#access_rights_for_territory" do
    it "returns nil when no access_rights founed" do
      territory = create(:territory)
      agent = create(:agent, organisations: [create(:organisation, territory: territory)])
      expect(agent.access_rights_for_territory(territory)).to be_nil
    end

    it "returns agent's agent_territorial_access_rights for given territorial" do
      territory = create(:territory)
      agent = create(:agent, organisations: [create(:organisation, territory: territory)])
      access_right = create(:agent_territorial_access_right, allow_to_manage_teams: true, agent: agent, territory: territory)
      expect(agent.access_rights_for_territory(territory)).to eq(access_right)
    end
  end

  describe "#multiple_organisations_access?" do
    it "return true with agent with 2 organisations" do
      agent = create(:agent, organisations: create_list(:organisation, 2))
      expect(agent.multiple_organisations_access?).to eq(true)
    end

    it "return false when agent allow to access multiple organisations" do
      agent = create(:agent, organisations: [create(:organisation)])
      expect(agent.multiple_organisations_access?).to eq(false)
    end
  end
end
