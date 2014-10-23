require 'rubygems'
require 'net/http'
require 'json'
require 'csv'
require 'google_drive'


=begin

###########What this does
This takes the first column of a google spreadsheet and reads in urls.
It then calls the api of import_io extractor and passes in that url
It writes the result in the second spreadsheet

###########Directions
In google drive, create a spreadsheet
The key will have a key=0AuNd2nrXNkQjdHhsdfs ... in the url.  Copy that key to gdrive_spreadsheet_key

In the first spreadsheet put all of the urls in the first column without a header

Copy all of your credentials below
Run the app and the results will be in the second spreadsheet.
 
  
=end

#usage
#rvm use ruby-1.9.3@rails3
#install gems
#irb -I .
#require 'parser'
#Parser.import_io
class Parser


    def self.import_io
      gdrive_login = "YOUR_GOOGLE_LOGIN"
      gdrive_pw = "YOUR_GOOGLE_PW"
      gdrive_spreadsheet_key = "YOUR_SPREADSHEET_KEY"
      import_io_key = "YOUR_IMPORT_IO_API_KEY"
      import_io_extractor_id = "YOUR_IMPORT_IO_EXTRACTOR_ID"
      import_io_user_id = "YOUR_IMPORT_IO_USER_ID"
      
      #log into google drive
     session = GoogleDrive.login( gdrive_login, gdrive_pw)
     p "post log-in"
     
     #get the first spreadsheet
     ws = session.spreadsheet_by_key(gdrive_key).worksheets[0]
     urls = []
     
     #iterates through the first column and stores the url in results
     for i in 1..ws.num_rows
        urls << ws[i,1]
      end

      #get the urls      
      p  urls.inspect
      
      
      import_io_api_key = gdrive_key
      extractor_id = import_io_extractor_id
     
      user = import_io_user_id
     
      json_results = []
      
      #iterate through all of the urls
      for r in urls
        url = "http://api.import.io/store/data/#{extractor_id}/_query?input/webpage/url=#{CGI.escape r}&_user=#{user}&_apikey=#{import_io_api_key}"
        
        uri = URI.parse( url )
        response =  Net::HTTP.get_response(uri)
   
        if response.body == ""
           p "response is blank"
          next
        end
       
        begin
          
          json_text = JSON.parse( response.body )
          json_results << json_text
          p "adding item to json result"
        rescue JSON::ParserError=>jse
          p "skipping because of json parse error"
          next
        end
        
      end
      
      p json_results   
      
       #write to the second spreadsheet
      session = GoogleDrive.login(gdrive_login, gdrive_pw)
   
           
       ws = session.spreadsheet_by_key(gdrive_spreadsheet_key).worksheets[1]
         
         
      #we write out all of the json results in the second spreadsheet
      json_results.each_with_index do |hash,row|
        p "processing: #{row}"
        result = hash["results"][0]
      
        p result
        
        #item is an array of the key and value
        result.each_with_index do |item,col|
          p item[1]
          p "#{row+1}, #{col+1}"
          
          
          ws[row+1, col+1] = item[1] 
          
        end
        
         
      
      end
      
      ws.save()
      
      
      
     
  
  end
  
     
end