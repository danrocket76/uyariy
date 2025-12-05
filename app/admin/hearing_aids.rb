ActiveAdmin.register HearingAid do
  # PERMISSIONS & MENU
  # Only Admins can manage inventory
  menu if: proc { current_user.admin? }

  permit_params :brand, :device_model, :price, :max_gain, :stock, :image_url, :battery_type, :bluetooth, :warranty, :technical_specs, :features

  # ------------------------------------------------
  # (Backend API for AI)
  # ------------------------------------------------
  collection_action :auto_fill, method: :post do
    brand = params[:brand]
    model = params[:model]

    if brand.blank? || model.blank?
      render json: { error: "Please enter Brand and Model first." }, status: 400
      return
    end

    data = ProductInfoGenerator.new(brand, model).fetch_data

    if data
      render json: data
    else
      render json: { error: "The Assistant could not find this product." }, status: 500
    end
  end

  # ------------------------------------------------
  # THE LIST VIEW (The Index)
  # ------------------------------------------------
  index do
    selectable_column
    id_column
    column :brand
    column :device_model
    column "Power (Gain)" do |product|
      "#{product.max_gain} dB"
    end
    column :price do |product|
      number_to_currency product.price
    end
    column :stock
    actions
  end

  # ------------------------------------------------
  # THE FILTERS (The Sidebar)
  # ------------------------------------------------
  filter :brand
  filter :device_model
  filter :max_gain
  filter :price

  # ------------------------------------------------
  # THE FORM (AI Auto Fill)
  # ------------------------------------------------
  form do |f|
    f.semantic_errors

    f.inputs "AI Power Tools" do
      li do
        span "Enter Brand and Model below, then click this button to auto-complete the specs."
        br
        # HERE GOES THE MAGIC OF THE AUTO FILL
        button "✨ Auto-Fill Specs with AI", id: "ai-autofill-btn", type: "button", class: "button", style: "background: #6f42c1; color: white; border: none; padding: 10px 20px; font-weight: bold; cursor: pointer;"
        span " Loading...", id: "ai-loading", style: "display: none; color: #666; margin-left: 10px;"
      end
    end

    f.inputs "Basic Info" do
      f.input :brand, input_html: { id: "input-brand" }
      f.input :device_model, input_html: { id: "input-model" }
      f.input :price
      f.input :stock
    end

    f.inputs "Technical Specs" do
      f.input :max_gain, label: "Max Gain (dB)", input_html: { id: "input-gain" }
      f.input :battery_type, as: :select, collection: ["Rechargeable", "312", "13", "675"], input_html: { id: "input-battery" }
      f.input :bluetooth, label: "Bluetooth Enabled?", input_html: { id: "input-bluetooth" }
      f.input :warranty, placeholder: "e.g., 3 Years", input_html: { id: "input-warranty" }
    end

    f.inputs "Rich Content" do
      f.input :image_url, hint: "Paste a URL for the product image"
      f.input :features, as: :text, input_html: { rows: 5, id: "input-features" }, hint: "List features separated by bullets or new lines."
      f.input :technical_specs, as: :text, label: "Full Description", input_html: { id: "input-description" }
    end

    f.actions

    # ------------------------------------------------
    #  Frontend Logic with JS
    # ------------------------------------------------
    script do
      raw <<~JAVASCRIPT
        document.addEventListener('DOMContentLoaded', function() {
          const btn = document.getElementById('ai-autofill-btn');
          const loader = document.getElementById('ai-loading');

          if (btn) {
            btn.addEventListener('click', function(e) {
              e.preventDefault();
              
              const brand = document.getElementById('input-brand').value;
              const model = document.getElementById('input-model').value;

              if (!brand || !model) {
                alert("Please type the Brand and Model first!");
                return;
              }

              // UI Feedback
              btn.disabled = true;
              btn.style.opacity = "0.7";
              loader.style.display = "inline";

              // Send Request
              fetch('/admin/hearing_aids/auto_fill', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ brand: brand, model: model })
              })
              .then(response => response.json())
              .then(data => {
                if (data.error) {
                  alert(data.error);
                } else {
                  // POPULATE FIELDS
                  document.getElementById('input-gain').value = data.max_gain;
                  document.getElementById('input-battery').value = data.battery_type;
                  document.getElementById('input-warranty').value = data.warranty;
                  document.getElementById('input-features').value = data.features;
                  document.getElementById('input-description').value = data.technical_specs;
                  
                  // Handle Checkbox (Bluetooth)
                  if (data.bluetooth) {
                    document.getElementById('input-bluetooth').checked = true;
                  }
                }
              })
              .catch(err => alert("AI Error: " + err))
              .finally(() => {
                btn.disabled = false;
                btn.style.opacity = "1";
                loader.style.display = "none";
              });
            });
          }
        });
      JAVASCRIPT
    end
  end
end