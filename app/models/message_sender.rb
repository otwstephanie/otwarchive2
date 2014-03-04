class MessageSender
  attr_reader :message, :recipients
  
  delegate :body, :to=>:message
  delegate :subject, :to=>:message


  def initialize message
    @message = message
    @recipients = message.recipient_list
  end

  def run
    deliver!
  end

  private
  def set_as_sent
    message.update_column(:sent_at, Time.zone.now)
    message.update_column(:editable, false)
  end

  def deliver!
    if recipients.any? && message.unsent?
      set_as_sent
      recipients.each { |pseud| deliver_to pseud }
    end
  end

  def deliver_to pseud
    attrs = {subject: subject, body: body, pseud: pseud, received_at: Time.zone.now, editable: false }
    message.children.create(attrs)
  end
end