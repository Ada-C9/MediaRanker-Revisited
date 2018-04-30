module ApplicationHelper
  def render_date(date)
    date.strftime("%b %e, %Y")
  end

  def readable_date(date)
  ("<span class='date'>" + date.strftime("%A, %b %d") + "</span>").html_safe
end
end
