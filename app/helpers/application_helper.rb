module ApplicationHelper
  def readable_date(date)
    ("<span class='date'>" + date.strftime("%b %d %Y") + "</span>").html_safe
  end

  def readable_money(money)
    #10 => $10.00
    #10.0 => $10.00
    #10.00 => $10.00
    #10.3333 => $10.33
    if !money
      return "$0.00"
    end
    money = money.to_s
    if money[-3] == "."
      return "$#{money}"
    elsif money[-2..-1] == ".0"
      return "$#{money}0"
    elsif
      money[-3..-1] == ".00"
      return "$#{money}"
    else
    end
  end
end
