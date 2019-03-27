# frozen_string_literal: true

require "rails_helper"

describe AssignmentPolicy do
  subject { AssignmentPolicy.new(user, assignment) }

  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  context "user is mentor" do
    let(:user) { @mentor }
    let(:assignment) { FactoryBot.create(:assignment, group: @group) }

    it { should permit(:admin_access) }
  end

  context "user is a group member" do
    let(:user) { @member }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    context "assignment is open" do
      let(:assignment) { FactoryBot.create(:assignment, group: @group, status: "open") }

      it { should_not permit(:admin_access) }
      it { should permit(:edit) }
      it { should permit(:start) }

      context "project is already submitted" do
        before do
          FactoryBot.create(:project, author: @member, assignment: assignment)
        end

        it { should_not permit(:start) }
      end
    end

    context "assignment is closed" do
      let(:assignment) { FactoryBot.create(:assignment, group: @group, status: "closed") }

      it { should_not permit(:start) }
      it { should_not permit(:edit) }
    end
  end
end
