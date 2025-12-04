class ProductInfoGenerator
  def initialize(brand, model)
    @brand = brand
    @model = model
  end

  def fetch_data
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:access_token])

    prompt = <<~PROMPT
      You are an expert audiologist. Provide technical specifications for the hearing aid: "#{@brand} #{@model}".
      
      Return a valid JSON object with these exact keys:
      - max_gain: (Estimate Integer, e.g., 60, 80, 105)
      - battery_type: (One of: "Rechargeable", "312", "13", "675")
      - bluetooth: (Boolean true/false)
      - warranty: (String, e.g. "3 Years")
      - features: (String with bullet points of key features)
      - technical_specs: (String, a professional marketing description of 2-3 sentences)
      
      If you are unsure, make a best educated guess based on the series tier.
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" }
      }
    )

    JSON.parse(response.dig("choices", 0, "message", "content"))
  rescue StandardError => e
    Rails.logger.error("AI Auto-Fill Error: #{e.message}")
    return nil
  end
end