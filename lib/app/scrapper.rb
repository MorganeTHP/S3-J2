require 'bundler'

class Scrapper
    attr_accessor :name, :email
    @@mail_list= Hash.new
    
    def self .get_townhall_email(townhall_url)
        page = Nokogiri::HTML(open(townhall_url))
        page.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').each do |node|
            return node.text
        end
    end

    def self .get_townhall_urls
        page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
        page.xpath("//tr[2]//p/a").each do |node|
            name = node.text
            email = get_townhall_email("http://annuaire-des-mairies.com/"+node["href"])
            @@mail_list[name] = email
        end
        return @@mail_list
    end

    def self .all
        return get_townhall_urls
    end

    def save_as_json
        File.open("db/emails.json","w") do |f|
            f.write(JSON.pretty_generate(@@mail_list)) # permet l’affichage avec retour à la ligne
        end
    end

    def self .save_as_csv
       CSV.open("db/email.csv", "w") do |csv|
         @@mail_list.each do |row|
           csv << row
            end
        end
   end


   def self .save_as_spreadsheet
      # Creation de la session manuellement
      session = GoogleDrive::Session.from_config("config.json")
      # On va checher le spreadsheets crée
      ws = session.spreadsheet_by_key("17NIuz0zM5w48ufypKmwvCavyWH93AERpYPpYvWzGZyw").worksheets[0]
      # On crée le header
      ws[1, 1] = "Ville"
      ws[1, 2] = "Email"
      # Fonction magique Update.cells qui lit un array de array
      ws.update_cells(2,1,Scrapper.all.to_a)
      ws.save
  end
end