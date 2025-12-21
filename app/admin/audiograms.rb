ActiveAdmin.register Audiogram do
  # Audiologists can READ and UPDATE (to validate), but they cant DELETE patient data
  menu if: proc {current_user.audiologist?}

  actions :all, except: [:destroy]

  permit_params :notes

  filter :user, label: "Patient"
  filter :created_at, label: "Date"
  filter :notes
  filter :image_file, as: :string, label: "File Name (Source)"


  # 1. The Clinical List
  index do
    selectable_column
    id_column
    column :user
    column "Date", :created_at
    column "Data Source" do |audio|
      audio.image_file.present? ? status_tag("AI Upload", class: :ok) : status_tag("Manual", class: :yes)
    end
    actions defaults: true do |audio|
      item "🖨️ Clinical Report", report_admin_audiogram_path(audio), class: "member_link", target: "_blank"
    end
  end

  # 2. The Clinical Detail View (The Analysis)
  show do
    # 1. Basic Details Table
    attributes_table do
      row :user
      row :created_at
      row :notes
    end

    # 2. Visual Audiogram
    panel "Clinical Analysis" do
      div style: "max-width: 600px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);" do
        canvas id: "adminAudiogramChart", height: "350"
      end

      # Load Chart.js
      script src: "https://cdn.jsdelivr.net/npm/chart.js"

      script do
        raw <<~JAVASCRIPT
          document.addEventListener("DOMContentLoaded", function() {
            const ctx = document.getElementById('adminAudiogramChart');
            
            // Data Injection
            const leftData = [
              #{audiogram.thresholds.dig('left', '125') || 0},
              #{audiogram.thresholds.dig('left', '250') || 0},
              #{audiogram.thresholds.dig('left', '500') || 0},
              #{audiogram.thresholds.dig('left', '1000') || 0},
              #{audiogram.thresholds.dig('left', '2000') || 0},
              #{audiogram.thresholds.dig('left', '4000') || 0},
              #{audiogram.thresholds.dig('left', '8000') || 0}
            ];

            const rightData = [
              #{audiogram.thresholds.dig('right', '125') || 0},
              #{audiogram.thresholds.dig('right', '250') || 0},
              #{audiogram.thresholds.dig('right', '500') || 0},
              #{audiogram.thresholds.dig('right', '1000') || 0},
              #{audiogram.thresholds.dig('right', '2000') || 0},
              #{audiogram.thresholds.dig('right', '4000') || 0},
              #{audiogram.thresholds.dig('right', '8000') || 0}
            ];

            new Chart(ctx, {
              type: 'line',
              data: {
                labels: ['125', '250', '500', '1k', '2k', '4k', '8k'],
                datasets: [
                  {
                    label: 'Right Ear (Red O)',
                    data: rightData,
                    borderColor: '#dc3545',
                    backgroundColor: '#dc3545',
                    pointStyle: 'circle',
                    pointRadius: 5,
                    fill: false,
                    tension: 0.1
                  },
                  {
                    label: 'Left Ear (Blue X)',
                    data: leftData,
                    borderColor: '#0d6efd',
                    backgroundColor: '#0d6efd',
                    pointStyle: 'crossRot',
                    pointRadius: 5,
                    fill: false,
                    tension: 0.1
                  }
                ]
              },
              options: {
                responsive: true,
                maintainAspectRatio: false, // Allows height setting
                scales: {
                  y: {
                    reverse: true,
                    min: -10,
                    max: 120,
                    title: { display: true, text: 'Hearing Level (dB)' }
                  }
                },
                plugins: {
                  legend: { position: 'bottom' }
                }
              }
            });
          });
        JAVASCRIPT
      end
    end

    # 3. Diagnosis Summary
    panel "Diagnosis Summary" do
      analysis = AudiogramAnalyzer.new(audiogram).analyze
      div class: "attributes_table" do
        table do
          tr do
            th "Diagnosis"
            td analysis[:diagnosis], style: "font-weight: bold; color: #333;"
          end
          tr do
            th "Left Ear Average"
            td "#{analysis[:left_ear][:pta]} dB (#{analysis[:left_ear][:severity]})"
          end
          tr do
            th "Right Ear Average"
            td "#{analysis[:right_ear][:pta]} dB (#{analysis[:right_ear][:severity]})"
          end
        end
      end
    end
  end

  # 3. Custom Action: Generate Report (PDF File)
  member_action :report, method: :get do
    @audiogram = resource
    @analysis = AudiogramAnalyzer.new(@audiogram).run
    render "admin/audiograms/report", layout: "active_admin"
  end
end