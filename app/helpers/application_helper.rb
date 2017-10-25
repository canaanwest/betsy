module ApplicationHelper
  def readable_date(date)
    ("<span class='date'>" + date.strftime("%A, %b %d") + "</span>").html_safe
  end



  def readable_money(money)
    #TODO: helper method that will format cost and revenue appropriate
    #10 =>  $10.00
    #10.0 => $10.00
    #10.00 => $10.00
    #10.3333 => $10.33
  end


end
