class CarsController < ApplicationController
    before_action :authenticate_user!
    def new 
        @cars = Car.new
    end

    def create_car

        id_car=params[:id]

        image = nil
        image = save_file(params[:photo],'images_car') if id_car.blank?
        @cars = Car.new if id_car.blank?
        @cars = Car.find(id_car) if !id_car.blank?
        @cars.name_car = params[:name_car]
        @cars.description = params[:description]
        @cars.photo = image if id_car.blank?
        @cars.model = params[:model]
        @cars.hour_cost = params[:hour_cost]
        @cars.review = 0
        @cars.rent_status = "Available" if 
        @cars.user_id = current_user.id
        @cars.save

        redirect_to '/'
    end

    def reserve_car

        validate_user = CarHasRent.where("user_id=? and rent_status='Activated' ", current_user.id)

        if validate_user.blank?

            hours = params[:rent_hours].to_i
            cost = params[:hour_cost].to_i
            rent_date = params[:reserve_date]

            if hours >= 3 and hours<= 36
                
                total_rent = (hours * cost)

                id_car=params[:id_car]

                @cars = Car.find(id_car) if !id_car.blank?
                @cars.rent_status = "Not Available"
                @cars.save

            

                @rent_car = CarHasRent.new
                @rent_car.car_id = id_car
                @rent_car.rent_hours = params[:rent_hours]
                @rent_car.rent_date = rent_date
                @rent_car.rent_cost = total_rent
                @rent_car.user_id = current_user.id
                @rent_car.rent_status = "Activated"
                
                @rent_car.save

                redirect_to '/'
            else

            end
        else
            redirect_to '/'
        end
    end

    def cancel_reserve

        rent_id=params[:rent_id]

        rent = CarHasRent.where("id=?", rent_id).take

        if !rent.blank?

            car = Car.find(rent.car_id)
            car.rent_status = "Available"
            car.save

            rent_car = CarHasRent.find(rent.id)
            rent_car.rent_status = "Canceled"
            rent_car.save

            redirect_to '/'
        else
            redirect_to '/'
        end
    end

    def review

        id_car =params[:rent_id]
        cars_review = CarHasRent.where("id=?", id_car).take
        review_car = params[:review_car].to_i
        cars_review.review = review_car
        cars_review.save

        car = Car.find(cars_review.car_id)
        rents = CarHasRent.where("car_id=? and review is not null",car.id)
        actual_reviews = (rents.map{|x| x["review"].to_f}).sum
        qty_rents = rents.count.to_f
        review_final = (actual_reviews/qty_rents ).to_f
        car.review = review_final
        car.save
        redirect_to '/'

    end
    
    def my_car

        @my_cars=Car.where("user_id=?",current_user.id)
        
    end

    def edit_car
        id_car=params[:id]
        @cars = Car.find(id_car) if !id_car.blank?
    end

    def index
        @cars=Car.where("rent_status = 'Available'")
    end

    def my_rent
        @rents=CarHasRent.getrents(current_user.id)
        rents=@rents.where('car_has_rents.rent_status = "Activated"').take
        if !rents.blank? 
            if rents.rent_date < Time.zone.today
                cars = Car.where("id = ?",rents.car_id).take
                cars.rent_status = "Available"
                cars.save
                rents.rent_status ='Rent Ended'
                rents.save
            end
        end
    end



    def view_car
        id_car=params[:id]
        @cars = Car.find(id_car) if !id_car.blank?
    end

    private

    def save_file(file,folder_img)
            ########SAVE images
            folder = "#{Rails.root}/public/#{folder_img}"
            name_file = (Time.new.to_s+'_'+file.original_filename).gsub(' ','')
            path = File.join(folder, name_file)
            File.open(path, "wb") { |f| f.write(file.read) };
            ################
            path_save = '/'+folder_img+'/'+name_file
            return path_save 
    end
    def delete_file(img)
        img_r="#{img}"
        if !img_r.blank?
          img = "#{Rails.root}/public/#{img}"  
          File.delete(img) if File.exist?(img)
        end
    end

end
