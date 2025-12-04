class AudiogramAnalyzer
  # The "Advanced" frequencies shown in your chart
  FREQUENCIES = ["125", "250", "500", "1000", "2000", "4000", "8000"]

  def initialize(audiogram)
    @audiogram = audiogram
    @data = audiogram.thresholds || {} # Handles nil/empty data
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
    # Extract values, converting to integer (default to 0 if missing)
    values = FREQUENCIES.map { |f| @data.dig(side, f).to_i }

    # Calculate PTA (Pure Tone Average) usually on 500, 1k, 2k, 4k
    pta_values = values.slice(2, 4) # 500, 1000, 2000, 4000
    pta = pta_values.sum / pta_values.size.to_f

    {
      frequencies: values,
      pta: pta.round(2),
      severity: calculate_severity(pta),
      max_loss: values.max # Used to find powerful enough hearing aids
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

    # Check for High Frequency Loss (common in aging)
    # If loss at 4k/8k is significantly worse than 500/1k
    left_high_freq_loss = (@data.dig("left", "8000").to_i > @data.dig("left", "500").to_i + 20)

    diagnosis = "Diagnosis: Left Ear (#{left[:severity]}), Right Ear (#{right[:severity]})."
    diagnosis += " High frequency drop-off detected." if left_high_freq_loss
    diagnosis
  end
end