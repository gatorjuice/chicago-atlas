require 'rails_helper'

RSpec.describe CategoryGroup, type: :model do
  describe "Factory validation check" do
    context "valid factory" do
      it "should be valid factory" do
        expect(FactoryGirl.create(:category_group)).to be_valid
      end
    end

    context "invalid factory" do
      it "should be invalid without name" do
        expect(FactoryGirl.build(:category_group, name: nil)).not_to be_valid
      end
    end
  end

  describe "ActiveRecord associations" do
    it { should have_many(:sub_categories) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
  end
end
