
require 'spec_helper'

describe ExportCardConfigurationsController do
  before do
    @controller.stub(:require_admin) { true }

    @default_config = FactoryGirl.create(:default_export_card_configuration)
    @custom_config = FactoryGirl.create(:export_card_configuration)
    @active_config = FactoryGirl.create(:active_export_card_configuration)
    @inactive_config = FactoryGirl.create(:inactive_export_card_configuration)

    @params = {}
    @valid_rows_yaml = "group1:\n  has_border: false\n  rows:\n    row1:\n      height: 50\n      priority: 1\n      columns:\n        id:\n          has_label: false"
  end

  describe 'Create' do
    it 'should let you create a configuration with all the values set' do
      @params[:export_card_configuration] = {
        name: "Config 1",
        rows: @valid_rows_yaml,
        per_page: 5,
        page_size: "A4",
        orientation: "landscape"
      }
      post 'create', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:notice_successful_create))
    end

    it 'should not let you create an invalid configuration' do
      @params[:export_card_configuration] = {
        name: "Config 1",
      }
      post 'create', @params

      response.should render_template('new')
    end
  end

  describe 'Update' do
    it 'should let you update a configuration' do
      @params[:id] = @custom_config.id
      @params[:export_card_configuration] = { per_page: 4}
      put 'update', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:notice_successful_update))
    end

    it 'should not let you update an invalid configuration' do
      @params[:id] = @custom_config.id
      @params[:export_card_configuration] = { per_page: "string"}
      put 'update', @params

      response.should render_template('edit')
    end

    it 'should not let you update a configuration with invalid rows yaml' do
      @params[:id] = @custom_config.id
      @params[:export_card_configuration] = { rows: "asdf ',#\""}
      put 'update', @params

      response.should render_template('edit')
    end
  end

  describe 'Delete' do
    it 'should let you delete a custom configuration' do
      @params[:id] = @custom_config.id
      delete 'destroy', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:notice_successful_delete))
    end

    it 'should not let you delete the default configuration' do
      @params[:id] = @default_config.id
      delete 'destroy', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:error_can_not_delete_export_card_configuration))
    end
  end

  describe 'Activate' do
    it 'should let you activate an inactive configuration' do
      @params[:id] = @inactive_config.id
      post 'activate', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:notice_export_card_configuration_activated))
    end
  end

  describe "Deactivate" do
    it 'should let you de-activate an active configuration' do
      @params[:id] = @active_config.id
      post 'deactivate', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:notice_export_card_configuration_deactivated))
    end

    it 'should not let you de-activate the default configuration' do
      @params[:id] = @default_config.id
      post 'deactivate', @params

      response.should redirect_to :action => 'index'
      flash[:notice].should eql(I18n.t(:error_can_not_deactivate_export_card_configuration))
    end
  end
end