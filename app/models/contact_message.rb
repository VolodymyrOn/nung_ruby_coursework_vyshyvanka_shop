class ContactMessage < ApplicationRecord
  STATUSES = %w[new read answered].freeze

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { maximum: 150 }
  validates :body, presence: true, length: { maximum: 5000 }

  validates :status, inclusion: { in: STATUSES }
end