class AudiogramImageExtractor
  require 'base64'

  def initialize(file_path)
    @file_path = file_path
  end

  def extract_data
    client = OpenAI::Client.new(access_token: Rails.application.credentials.openai[:access_token])

    # Convert image to Base64
    image_data = Base64.strict_encode64(File.read(@file_path))

    response = client.chat(
      parameters: {
        model: "gpt-4o", # The vision model
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: system_prompt },
              {
                type: "image_url",
                image_url: {
                  url: "data:image/jpeg;base64,#{image_data}"
                }
              }
            ]
          }
        ],
        response_format: { type: "json_object" } # Critical: Forces valid JSON
      }
    )

    # Clean and parse the response
    json_string = response.dig("choices", 0, "message", "content")
    JSON.parse(json_string)
  rescue StandardError => e
    Rails.logger.error("AI Analysis Failed: #{e.message}")
    return nil
  end

  private

  def system_prompt
    <<~PROMPT
      You are an expert audiologist analyzing an audiogram chart.
      
      TASK:
      Extract the Hearing Level (dB) for the Left Ear and Right Ear at specific frequencies.
      
      LEGEND:
      - Left Ear: Marked by "X" symbols or Blue lines.
      - Right Ear: Marked by "O" symbols or Red lines.
      - Grid: Top is 0 dB (Low loss), Bottom is 120 dB (High loss).
      
      INSTRUCTIONS:
      1. Identify values for these frequencies: 125, 250, 500, 1000, 2000, 4000, 8000 Hz.
      2. If a specific point is missing or unclear, estimate it based on the line trajectory.
      3. Return ONLY a raw JSON object. No markdown formatting.
      
      REQUIRED JSON STRUCTURE:
      {
        "left": { "125": 10, "250": 15, "500": 20, "1000": 25, "2000": 30, "4000": 35, "8000": 40 },
        "right": { "125": 10, "250": 15, "500": 20, "1000": 25, "2000": 30, "4000": 35, "8000": 40 }
      }
    PROMPT
  end
end