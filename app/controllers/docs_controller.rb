class DocsController < ApplicationController
  before_action :set_doc, only: [:show, :edit, :update, :destroy]

  # GET /docs
  # GET /docs.json
  def index
    @docs = Doc.all
  end

  # GET /docs/1
  # GET /docs/1.json
  def show
  end

  def history_and_physical
    respond_to do |format|
      format.pdf do
        require "prawn"

        pdf = Prawn::Document.new do
          # text "Hello World!"
          draw_text "Recipet", at: [220, 575], size: 22
        end
        
        send_data pdf.render, type: "application/pdf"
      end
    end
    
  end
  
  # GET /docs/new
  def new
    @doc = Doc.new
  end

  # GET /docs/1/edit
  def edit
  end

  # POST /docs
  # POST /docs.json
  def create
    @doc = Doc.new(doc_params)

    respond_to do |format|
      if @doc.save
        format.html { redirect_to @doc, notice: 'Doc was successfully created.' }
        format.json { render :show, status: :created, location: @doc }
      else
        format.html { render :new }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /docs/1
  # PATCH/PUT /docs/1.json
  def update
    # choose only attributes for which the prior value matches the current 
    # value (stored in the database). Otherwise there is concern that 
    # someone else may have updated in between
    params[:prior_values] ||= {}
    
    # reject any key-value pairs in which the client's "prior value" does not 
    # match the database's pre-updated value (a sign that someone else has  
    # updated this model in the interim)
    rejected_pairs = doc_params
      .select {|k,v| v != params[:prior_values][k]} # first choose k-v pairs that were updated
      .select {|k,v| @doc.attributes[k] != params[:prior_values][k]} # second, choose k-v pairs that have mismatch between client's and database's prior values
    
    # We don't want to lose all data, so still update the ones that changed
    # appropriately
    doc_params_matching_original_value = doc_params
      .select {|k,v| @doc.attributes[k] == params[:prior_values][k]} 
    
    
    respond_to do |format|
      if @doc.update(doc_params_matching_original_value)
        if rejected_pairs.any?
          rejected_pairs.each do |k,v|
            @doc.errors.add(k, "was edited concurrently somewhere else")
          end
          format.html { render :edit }
          format.json { render json: @doc.errors, status: :conflict }
        else
          format.html { redirect_to @doc, notice: 'Doc was successfully updated.' }
          format.json { render :show, status: :ok, location: @doc }
        end
      else
        format.html { render :edit }
        format.json { render json: @doc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docs/1
  # DELETE /docs/1.json
  def destroy
    @doc.destroy
    respond_to do |format|
      format.html { redirect_to docs_url, notice: 'Doc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
      @doc = Doc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def doc_params
      params.permit(:one_liner, :checklist, :interval_events, :history_of_present_illness, :past_medical_history, :medications, :family_history, :social_history, :emergency_contact, :exam, :data, :assessment_and_plan, :plan_archive, :event_archive )
      
    end
end
