class Receipt < ApplicationRecord
  belongs_to :expense

  validates :file_url, :file_name, :file_type, :amount, :receipt_date, presence: true
  validates :amount, numericality: { greater_than: 0 }

def process!
   update(processed_at: Time.current, status: 'processed')
   # we can add our processing logic here in future
   true
   rescue StandardError => e
     Rails.logger.error("Failed to process receipt #{id}: #{e.message}")
     false
   end

end
