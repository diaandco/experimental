require "spec_helper"

describe Experimental::Subject do
  include Experimental::RspecHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:experiment_name) { "exp" }
  let(:experiment) { FactoryGirl.create(:experiment, name: experiment_name) }
  let(:unstarted_experiment) { FactoryGirl.create(:experiment, :unstarted) }

  describe "#in_experiment?" do
    context "in experiment" do
      include_context "in experiment"

      it "returns true" do
        user.in_experiment?(experiment_name).should be_truthy
      end
    end

    context "not in experiment" do
      include_context "not in experiment"

      it "returns false" do
        user.in_experiment?(experiment_name).should be_falsey
      end
    end

    context "given an invalid experiment name" do
      it "returns false" do
        user.in_experiment?(:doesnt_exist).should be_falsey
      end
    end

    context "experiment is not started" do
      it "returns false" do
        user.in_experiment?(unstarted_experiment.name).should be false
      end
    end
  end

  describe "#not_in_experiment?" do
    context "not in experiment" do
      include_context "not in experiment"

      it "returns true" do
        user.not_in_experiment?(experiment_name).should be_truthy
      end
    end

    context "in experiment" do
      include_context "in experiment"

      it "returns false" do
        user.not_in_experiment?(experiment_name).should be_falsey
      end
    end

    context "given an invalid experiment name" do
      it "returns true" do
        user.not_in_experiment?(:doesnt_exist).should be_truthy
      end
    end

    context "experiment is not started" do
      it "returns true" do
        user.not_in_experiment?(unstarted_experiment.name).should be true
      end
    end
  end

  describe "#experiment_bucket" do
    context "user is not in experiment" do
      before { Experimental::Experiment.any_instance.stub(in?: false) }

      it "returns nil" do
        user.experiment_bucket(experiment_name).should be_nil
      end
    end

    context "user is in experiment" do
      context "user is in bucket 0" do
        include_context "in experiment bucket 0"

        it "returns 0" do
          user.experiment_bucket(experiment_name).should be_zero
        end
      end

      context "user is in bucket 1" do
        include_context "in experiment bucket 1"

        it "returns 1" do
          user.experiment_bucket(experiment_name).should == 1
        end
      end
    end

    context "experiment does not exist" do
      it "returns nil" do
        user.experiment_bucket(:doesnt_exist).should be_nil
      end
    end
  end

  describe "#in_bucket?" do
    context "user is in experiment" do
      include_context "in experiment bucket 0"

      context "given the user's experiment bucket" do
        it "returns true" do
          user.in_bucket?(experiment_name, 0).should be_truthy
        end
      end

      context "not given the user's experiment bucket" do
        it "returns false" do
          user.in_bucket?(experiment_name, 1).should be_falsey
        end
      end
    end
    context "user is not in experiment" do
      include_context "not in experiment"
      before do
        has_experiment_bucket(0)
      end
      context "given the user's experiment bucket" do
        it "returns false" do
          user.in_bucket?(experiment_name, 0).should be_falsey
        end
      end

      context "not given the user's experiment bucket" do
        it "returns false" do
          user.in_bucket?(experiment_name, 1).should be_falsey
        end
      end
    end
  end

  describe "#experiment_seed_value" do
    it "returns the subject ID by default" do
      user.experiment_seed_value.should == user.id
    end
  end

  context "when obj isn't user" do
    let(:test_obj) { FactoryGirl.create(:user) }
    let(:exp_name2) { "exp2" }

    before do
      is_in_experiment(true, exp_name2, test_obj)
    end

    it "returns true" do
      test_obj.in_experiment?(exp_name2).should be_truthy
    end
  end
end
