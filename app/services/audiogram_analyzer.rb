class AudiogramAnalyzer

  FREQUENCIES = ["125", "250", "500", "1000", "2000", "4000", "8000"]

  def initialize(audiogram)
    @audiogram = audiogram
    @data = audiogram.thresholds || {}
  end


  def analyze
    {
      left_ear: analyze_ear("left"),
      right_ear: analyze_ear("right"),
      diagnosis: generate_clinical_diagnosis
    }
  end

  private

  def analyze_ear(side)

    values = FREQUENCIES.map { |f| @data.dig(side, f).to_i }

    # Calcular PTA (Promedio de Tonos Puros)
    pta_values = values.slice(2, 4)


    if pta_values && pta_values.any?
      pta = pta_values.sum / pta_values.size.to_f
    else
      pta = 0
    end

    {
      frequencies: values,
      pta: pta.round(2),
      severity: calculate_severity(pta),
      max_loss: values.max || 0
    }
  end

  def calculate_severity(avg)
    case avg
    when -Float::INFINITY..20 then "Normal"
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

    diagnosis = "Diagnosis: Left Ear (#{left[:severity]}), Right Ear (#{right[:severity]})."


    left_8k = @data.dig("left", "8000").to_i
    left_500 = @data.dig("left", "500").to_i

    if left_8k > (left_500 + 20)
      diagnosis += " High frequency drop-off detected."
    end

    diagnosis
  end
end