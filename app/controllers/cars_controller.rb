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

        flash[:car_save] = "Create Car succesful" if id_car.blank?
        flash[:car_save] = "Edit Car succesful" if !id_car.blank?

        redirect_to '/'
    end

    def reserve_car

        rent_id = params[:rent_id]

        validate_user = nil
        validate_user = CarHasRent.where("user_id=? and rent_status='Activated' ", current_user.id) if rent_id.blank?

        if validate_user.blank?

            cost_rent = params[:cost_rent].to_i
            

            rent_date = params[:date_from]
            rent_date_to = params[:date_to]
            @rent_car = CarHasRent.find(rent_id) if !rent_id.blank?
            id_car = params[:id_car]
            id_car = @rent_car.car_id if params[:id_car].blank?
            hours = params[:rent_hours].to_i

            @cars = Car.find(id_car) if !id_car.blank?
            @cars.rent_status = "Not Available"
            @cars.save

            @rent_car = CarHasRent.new if rent_id.blank?
            @rent_car.car_id = id_car
            @rent_car.rent_hours = hours
            @rent_car.rent_date = rent_date
            @rent_car.rent_date_to = rent_date_to
            @rent_car.rent_cost = cost_rent
            @rent_car.user_id = current_user.id
            @rent_car.rent_status = "Activated"
            @rent_car.save

            flash[:rent_car] = "Rent Car Succesful"
            flash[:rent_car] = "Modify Car Succesful" if !rent_id.blank?
            redirect_to '/'
        else
            flash[:not_rent_car] = "User with Rent Active"
            redirect_to '/'
        end
    end

    def calculate_cost_rent

        cost = params[:hour_cost].to_i
        rent_date_from = params[:reserve_date_from]
        rent_date_to = params[:reserve_date_to]
        url = params[:url_h]
        date_from =  Date.parse(rent_date_from.split("T").first)
        date_to =  Date.parse(rent_date_to.split("T").first)
        hour_from = rent_date_from.to_time

        hour_to = rent_date_to.to_time

        valid_hour = (hour_to - hour_from)

        if valid_hour >= 10800  and valid_hour <= 129600

            hours = (valid_hour / 3600).to_i
            total_rent = (hours * cost)
            flash[:total_rent] = total_rent
            flash[:rent_hours] = hours
            flash[:date_from] = date_from
            flash[:date_to] = date_to
        else
            flash[:invalid_hour] = "Invalid Hour"
        end


       
        redirect_to url
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

            flash[:cancel_rent] = "Cancel Rent Succesful"

            redirect_to '/'
        else
            redirect_to '/'
        end
    end

    def review

        rent_id =params[:rent_id]
        cars_review = CarHasRent.where("id=?", rent_id).take
        
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
        flash[:review_rent] = "Review Car Succesful"
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
        @rents=CarHasRent.getrents.where('car_has_rents.user_id=?',current_user.id)
        rents=@rents.where('car_has_rents.rent_status = "Activated"').take
        time_end = Time.now.strftime('%F').to_date

        if !rents.blank? 
            if rents.rent_date_to < time_end
                cars = Car.where("id = ?",rents.car_id).take
                cars.rent_status = "Available"
                cars.save
                rents.rent_status ='Rent Ended'
                rents.save
                
            end
        end
    end

    def view_car
        id_car = params[:id]
        @cars = Car.find(id_car) if !id_car.blank?
    end

    def modify_rent
        rent_id = params[:id] if params[:id]
        @rent_modify = CarHasRent.getrents.where('car_has_rents.id=?',rent_id).take if !rent_id.blank?
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
