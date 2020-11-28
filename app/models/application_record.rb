class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def rollback_state
    begin
      yield
    rescue Exception => e
      p self.reload.methods(false)
      self.copy_state = self.reload.aasm.current_state
      self.save
      raise e
    end
  end
end
