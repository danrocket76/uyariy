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
        model: "gpt-4o", # We specify the vision model
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
        response_format: { type: "json_object" } # We force it to obtain valid JSON
      }
    )

    # This will clean and parse the response
    json_string = response.dig("choices", 0, "message", "content")
    JSON.parse(json_string)
  rescue StandardError => e
    Rails.logger.error("AI Analysis Failed: #{e.message}")
    return nil
  end

  private

  def system_prompt
    <<~PROMPT
        You are an expert clinical audiologist specializing in reading complex audiometric charts.
        Your task is to extract ONLY the standard Air Conduction (AC) thresholds from the provided image of an audiogram.

        CRITICAL INSTRUCTIONS FOR SYMBOL RECOGNITION:
        1.  **Target Symbols ONLY:**
            * For the **RIGHT EAR**, you must ONLY look for **Red Circles (O)** connected by a solid red line.
            * For the **LEFT EAR**, you must ONLY look for **Blue Crosses/X's (X)** connected by a solid blue line.
        2.  **IGNORE NOISE:** Aggressively IGNORE all other symbols (BC, MCL, UCL) like '<', '>', '[', ']', arrows pointing down, 'M', or 'U'. Do NOT mistake a bone conduction bracket for an air conduction threshold.

        READING THE GRID:
        * The Y-axis is Hearing Level (dB HL). It is inverted. **0 dB is at the top**. 120 dB is at the bottom.
        * **IMPORTANT SCALE NOTE:** The major horizontal grid lines are 20 dB apart (0, 20, 40, 60, 80, 100, 120). There is a fainter grid line at the 10 dB, 30 dB, 50 dB, etc. marks. **Estimate the threshold to the nearest 5 dB increment.**
        * X-axis Frequencies (Hz): 125, 250, 500, 1000, 2000, 4000, 8000.

        OUTPUT FORMAT:
        You must return ONLY a raw JSON object. Do not include markdown formatting like ```json at the start or end.
        If a frequency point is missing or unreadable for an ear, set its value to null.

        Required JSON Structure:
        {
          "left": {
            "125": <int or null>, "250": <int or null>, "500": <int or null>, "1000": <int or null>,
            "2000": <int or null>, "4000": <int or null>, "8000": <int or null>
          },
          "right": {
            "125": <int or null>, "250": <int or null>, "500": <int or null>, "1000": <int or null>,
            "2000": <int or null>, "4000": <int or null>, "8000": <int or null>
          }
        }
      PROMPT
  end
end