
from twilio.rest import Client

# Your Twilio account credentials
account_sid = 'account_sid'
auth_token = 'your_auth_token'
twilio_number = '+twilio_number'
target_phone_number = '+your_phone_number'

client = Client(account_sid, auth_token)

def send_sms(message):
    client.messages.create(
        body=message,
        from_=twilio_number,
        to=target_phone_number
    )

if __name__ == "__main__":
    message = "Brute force attack detected on SSH server!"
    send_sms(message)

