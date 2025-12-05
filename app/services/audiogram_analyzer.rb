class AudiogramAnalyzer
  # The whole frequencies that are shown in the chart
  FREQUENCIES = ["125", "250", "500", "1000", "2000", "4000", "8000"]

  def initialize(audiogram)
    @audiogram = audiogram
    @data = audiogram.thresholds || {}
  end

  def run
    {
      left_ear: analyze_ear("left"),
      right_ear: analyze_ear("right"),
      diagnosis: generate_clinical_diagnosis
    }
  end

  private

  def analyze_ear(side)
    # We extract the values, and convert it to an integer (default it to 0 if missing)
    values = FREQUENCIES.map { |f| @data.dig(side, f).to_i }

    # Calculate PTA (Pure Tone Average) they're usually on 500, 1k, 2k, 4k frequencies
    pta_values = values.slice(2, 4)
    pta = pta_values.sum / pta_values.size.to_f

    {
      frequencies: values,
      pta: pta.round(2),
      severity: calculate_severity(pta),
      max_loss: values.max # This will be used to find powerful hearing aids that are good enough for the patient
    }
  end

  def calculate_severity(avg)
    case avg
    when -20..20 then "Normal"
    when 21..40 then "Mild"
    when 41..55 then "Moderate"
    when 56..70 then "Moderately Severe"
    when 71..90 then "Severe"
    else "Profound"
    end
  end

  def generate_clinical_diagnosis
    left = analyze_ear("left")
    right = analyze_ear("right")

    # Check for High Frequency Loss (this is common in aging)
    left_high_freq_loss = (@data.dig("left", "8000").to_i > @data.dig("left", "500").to_i + 20)
    diagnosis = "Diagnosis: Left Ear (#{left[:severity]}), Right Ear (#{right[:severity]})."
    diagnosis += " High frequency drop-off detected." if left_high_freq_loss
    diagnosis
  end
end