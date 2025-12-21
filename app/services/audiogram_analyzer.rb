class AudiogramAnalyzer
  # Definimos las frecuencias exactas que usamos en el gráfico
  FREQUENCIES = ["125", "250", "500", "1000", "2000", "4000", "8000"]

  def initialize(audiogram)
    @audiogram = audiogram
    @data = audiogram.thresholds || {}
  end

  # IMPORTANTE: Renombramos 'run' a 'analyze' para que el AudiogramsController lo encuentre.
  def analyze
    {
      left_ear: analyze_ear("left"),
      right_ear: analyze_ear("right"),
      diagnosis: generate_clinical_diagnosis
    }
  end

  private

  def analyze_ear(side)
    # Extraemos los valores y convertimos a entero (si falta alguno, default a 0 para no romper cálculos)
    values = FREQUENCIES.map { |f| @data.dig(side, f).to_i }

    # Calcular PTA (Promedio de Tonos Puros)
    # Tu lógica aquí es excelente: tomamos 500, 1k, 2k, 4k (indices 2,3,4,5)
    pta_values = values.slice(2, 4)

    # Evitar división por cero si algo sale mal con los datos
    if pta_values && pta_values.any?
      pta = pta_values.sum / pta_values.size.to_f
    else
      pta = 0
    end

    {
      frequencies: values,
      pta: pta.round(2),
      severity: calculate_severity(pta),
      # max_loss es vital para la Factory y el Controller nuevo (Smart Match)
      max_loss: values.max || 0
    }
  end

  def calculate_severity(avg)
    case avg
    when -Float::INFINITY..20 then "Normal" # Abarca valores negativos hasta 20
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

    # Diagnóstico base
    diagnosis = "Diagnosis: Left Ear (#{left[:severity]}), Right Ear (#{right[:severity]})."

    # Chequeo de caída en frecuencias altas (Tu lógica avanzada)
    # Comparamos 8000Hz vs 500Hz
    left_8k = @data.dig("left", "8000").to_i
    left_500 = @data.dig("left", "500").to_i

    if left_8k > (left_500 + 20)
      diagnosis += " High frequency drop-off detected."
    end

    diagnosis
  end
end