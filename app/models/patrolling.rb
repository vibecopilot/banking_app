class Patrolling < ApplicationRecord
  belongs_to :site
  belongs_to :building
  belongs_to :floor
  belongs_to :unit
  has_many :activities
  has_many :checklists 
  has_many :submissions
  has_many :patrolling_histories, dependent: :destroy
  
  validates :site_id, presence: true
  
  after_create :enqueue_qr_generation
  after_create :enqueue_history_creation
  after_create :generate_qr_code
  has_one :qr_code_image, -> { where(relation: "PatrollingQR") }, 
          foreign_key: :relation_id, class_name: "Attachfile"
  
  serialize :specific_times, Array

  def generate_qr_code
    qr_code = RQRCode::QRCode.new("patrollings_scan_qr_path/#{self.id}", size: 10, level: :h)
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 200,
      border_modules: 4,
      module_px_size: 6
    )
    
    temp_file = Tempfile.new(["patrolling_#{self.id}", '.png'])
    temp_file.binmode
    temp_file.write(png.to_s)
    temp_file.rewind
    
    Attachfile.create(
      image: temp_file, 
      relation: "PatrollingQR", 
      relation_id: self.id, 
      active: 1
    )
    
    temp_file.close
    temp_file.unlink
  end

  private

  def enqueue_qr_generation
    GeneratePatrollingQrJob.perform_later(self.id)
  end

  def enqueue_history_creation
    CreatePatrollingHistoriesBatchJob.perform_later([self.id])
  end
end
