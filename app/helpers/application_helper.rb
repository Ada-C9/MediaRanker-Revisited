module ApplicationHelper
  def render_date(date)
    date.strftime("%b %e, %Y")
  end

  def email_or_name(user)
    return user.name ? user.name : user.email
  end
end
