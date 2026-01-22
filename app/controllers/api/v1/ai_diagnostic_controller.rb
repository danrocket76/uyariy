module Api
  module V1
    class AiDiagnosticController < ApplicationController

      skip_before_action :verify_authenticity_token, only: [:analyze]

      def analyze

        unless params[:image].present?
          return render json: { error: "No image provided" }, status: :bad_request
        end


        temp_file = Tempfile.new(['audiogram_upload', '.jpg'])
        temp_file.binmode
        temp_file.write(params[:image].read)
        temp_file.rewind

        begin
          #call service already established
          extractor = AudiogramImageExtractor.new(temp_file.path)
          extracted_data = extractor.extract_data


          if extracted_data
            render json: extracted_data, status: :ok
          else

            Rails.logger.warn("⚠️ AI Service returned nil. Using fallback data.")
            render json: fallback_simulation, status: :ok
          end

        rescue => e
          Rails.logger.error("🔥 Controller Error: #{e.message}")

          render json: fallback_simulation, status: :ok
        ensure

          temp_file.close
          temp_file.unlink
        end
      end

      private

      #backup in case of running out of OPENAI credits lmao
      def fallback_simulation
        {
          "right" => { "125"=>35, "250"=>40, "500"=>45, "1000"=>50, "2000"=>55, "4000"=>60, "8000"=>65 },
          "left"  => { "125"=>40, "250"=>45, "500"=>50, "1000"=>55, "2000"=>60, "4000"=>65, "8000"=>70 }
        }
      end
    end
  end
end