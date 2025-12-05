ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }, if: proc { current_user.admin? }

  content title: proc { I18n.t("active_admin.dashboard") } do

    # --- HERE WE PUT THE BIG STATS ---
    columns do
      column do
        panel "Total Revenue" do
          div class: "kpi-container" do
            total = Order.sum(:total_amount)
            div number_to_currency(total), class: "kpi-value text-green"
            div "Lifetime Sales", class: "kpi-label"
          end
        end
      end

      column do
        panel "Appointments Pending" do
          div class: "kpi-container" do
            count = Appointment.where(status: :pending).count
            div count, class: "kpi-value text-orange"
            div "Needs Action", class: "kpi-label"
          end
        end
      end

      column do
        panel "Total Users" do
          div class: "kpi-container" do
            div User.count, class: "kpi-value text-blue"
            div "Registered Patients", class: "kpi-label"
          end
        end
      end
    end

    # --- HERE GOES THE STORE DATA ---
    columns do
      column do
        panel "Inventory Levels" do
          table_for HearingAid.order("stock ASC").limit(10) do
            column :brand
            column :device_model
            column "Stock" do |h|
              if h.stock == 0
                status_tag "Out", class: "error"
              elsif h.stock < 5
                status_tag "#{h.stock} Low", class: "warn"
              else
                status_tag h.stock, class: "ok"
              end
            end
            column :price do |h| number_to_currency h.price end
          end
        end
      end

      column do
        panel "Recent Payment History" do
          if Order.any?
            table_for Order.order("created_at desc").limit(10) do
              column("ID") { |o| link_to "##{o.id}", admin_order_path(o) }
              column :total_amount do |o| number_to_currency o.total_amount end
              column :created_at
              column :status do |o| status_tag o.status, class: "ok" end
            end
          else
            div "No payments yet.", style: "padding: 20px; text-align: center; color: #aaa;"
          end
        end
      end
    end

    # --- HERE THE CLINIC DATA ---
    columns do
      column do
        panel "Upcoming Appointments" do
          table_for Appointment.where("appointment_date >= ?", Time.now).limit(5) do
            column :user
            column("Date") { |a| a.appointment_date.strftime("%b %d") }
            column :reason
            column :status do |a| status_tag a.status, class: a.status end
          end
        end
      end

      column do
        panel "Recent Audiologist Validations" do
          table_for Recommendation.where.not(validated_at: nil).order("validated_at desc").limit(5) do
            column :user
            column :hearing_aid
            column("Validated") { |r| time_ago_in_words(r.validated_at) + " ago" }
          end
        end
      end
    end

  end
end