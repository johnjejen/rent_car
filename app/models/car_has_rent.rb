class CarHasRent < ApplicationRecord
  belongs_to :car
  belongs_to :user

  def self.getrents(user_id)
		CarHasRent.select('cars.id,cars.name_car, cars.model,cars.photo, car_has_rents.*')
		.joins('inner join cars on cars.id= car_has_rents.car_id')
		.where('car_has_rents.user_id = ?', user_id)
	end

end
