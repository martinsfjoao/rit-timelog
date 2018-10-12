require 'sinatra'
require 'rubygems'
require 'selenium-webdriver'
require 'date'
require 'time'
require "json"
require 'phantomjs'


class App < Sinatra::Base

    post "/timelog" do
      payload = params 
      request.body.rewind
      payload = JSON.parse request.body.read      
      puts "Payload received:" 
      puts payload
      
      Selenium::WebDriver::PhantomJS.path = 'C:\Users\jmartins\Downloads\phantomjs-2.1.1-windows\phantomjs-2.1.1-windows\bin\phantomjs.exe'
      @driver = Selenium::WebDriver.for :phantomjs
      #@driver.manage.window.resize_to(1300,500)
      @driver.navigate.to 'https://app4.timelog.com/readinessit/Registration/TimeTracking'
      sleep 2
      
      account_input = @driver.find_element(:id, 'shortname')
      username_input = @driver.find_element(:id, 'username')
      password_input = @driver.find_element(:id, 'password')
      login_button = @driver.find_element(:xpath, '//input[contains(@class,"btn")]')
      
      project_inputs = @driver.find_elements(:xpath, '//tr[contains(.,"Panama") and contains(@class,"has-arrow")]//input')
      spanish_ipunts = @driver.find_elements(:xpath, '//tr[contains(.,"Panama") and contains(@class,"has-arrow")]//input')
      
      
      
      if account_input.displayed?
          puts "Logging in: #{payload["options"]["username"]}"
          account_input.send_keys "readinessit"
          username_input.send_keys payload["options"]["username"]
          password_input.send_keys payload["options"]["password"]
          login_button.click
      end
      
      sleep 2
      
      main_search_input = @driver.find_element(:id, 'timeTrackingMainSearch')
      date_input = @driver.find_element(:xpath, './/input[contains(@class,"dateInput")]')
      hours_input = @driver.find_element(:id, 'txtDuration')
      save_button = @driver.find_element(:id, 'btnSave')
      submit_button = @driver.find_element(:id, 'btnClosePeriodOpener')
      
      datey = Date.today
      monday = (datey - datey.wday + 1).strftime('%d/%m/%Y')
      
      #sleep 2
      
      payload["projects"].each do |project|
          project["hours"].length.times do |i|
              if project["hours"][i]
                  puts "Going to fill the Project: #{project["name"]}"
                  main_search_input.send_keys project["name"]
      
                  sleep 3
      
                  search_result = @driver.find_element(:class, 'search-result-item')
                  search_result.click
      
                  sleep 2
      
                  date_to_fill = (datey - datey.wday + 1 + i).strftime('%d/%m/%Y')
                  puts "Going to fill the Day: #{date_to_fill}"
                  date_input.clear
                  date_input.send_keys date_to_fill
                  puts "With: #{project["hours"][i]} hours"
                  hours_input.send_keys project["hours"][i]
      
                  sleep 2
                  puts "Saving hours"
                  save_button.click
              end
          end
      end
      
      sleep 2
      puts "Filled all the hours"
      
      if payload["options"]["close_week"]
          puts "Going to Submit for approval"
          submit_button.click
          sleep 2
          send_button = @driver.find_element(:id, 'btnClosePeriod')
          send_button.click
      else
          puts "Not going to Submit for approval"
      end
      
      sleep 2

      puts "Done"
      
      @driver.quit
    end

  end