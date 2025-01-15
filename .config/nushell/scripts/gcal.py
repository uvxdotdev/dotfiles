import datetime
import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError


def create_google_calendar_event(summary, description, start_time, end_time, attendees):
    """
    Create a Google Calendar event and send invites to attendees.

    :param summary: Event title
    :param description: Event description
    :param start_time: Event start time (datetime object)
    :param end_time: Event end time (datetime object)
    :param attendees: List of email addresses to invite
    :return: Created event details or None if an error occurs
    """
    # If modifying these scopes, delete the file token.json.
    SCOPES = ["https://www.googleapis.com/auth/calendar"]

    creds = None
    timezone = "Asia/Kolkata"
    # The file token.json stores the user's access and refresh tokens
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)

    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)

        # Save the credentials for the next run
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    try:
        service = build("calendar", "v3", credentials=creds)

        # Prepare event details
        event = {
            "summary": summary,
            "description": description,
            "start": {
                "dateTime": start_time.isoformat(),
                "timeZone": timezone,  # Replace with your timezone (e.g., 'America/New_York')
            },
            "end": {
                "dateTime": end_time.isoformat(),
                "timeZone": timezone,  # Replace with your timezone
            },
            "attendees": [{"email": email} for email in attendees],
            "sendInvites": True,  # This will send email invitations
        }

        # Create the event
        event = service.events().insert(calendarId="primary", body=event).execute()
        print(f'Event created: {event.get("htmlLink")}')
        return event

    except HttpError as error:
        print(f"An error occurred: {error}")
        return None


def main():
    summary = "Team Meeting"
    description = "Weekly team sync-up"
    start_time = datetime.datetime(
        2024, 12, 15, 10, 0, 0
    )  # Year, Month, Day, Hour, Minute, Second
    end_time = datetime.datetime(2024, 12, 15, 11, 0, 0)
    attendees = ["atrimbakkar05@gmail.com"]

    create_google_calendar_event(summary, description, start_time, end_time, attendees)


if __name__ == "__main__":
    main()
