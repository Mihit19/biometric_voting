import serial
import pyrebase
import time

# Firebase configuration
config = {
    "apiKey": "AIzaSyC803MPncl2WMtK8PX1oiIlB9xDNTiPWVc",
    "authDomain": "biometric-voting-machine-cb2f3",
    "databaseURL": "https://biometric-voting-machine-cb2f3-default-rtdb.firebaseio.com",
    "storageBucket": "biometric-voting-machine-cb2f3.firebasestorage.app"
}

firebase = pyrebase.initialize_app(config)
database = firebase.database()

# Serial communication setup
arduino = serial.Serial("/dev/ttyUSB0", 9600, timeout=1)
time.sleep(2)

print("Start. (CTRL + C to Exit.)")

# Function to add user ID to Firebase
def register_user_to_firebase(user_id, name):
    user_data = {
        "name": name,
        "voted": False  # Initial state, 'voted' is set to False
    }
    database.child("users").child(user_id).set(user_data)
    print(f"User {user_id} registered in Firebase with name: {name}")

def arduino_register_command(user_id):
    while True:
        print("register: ", user_id)
        arduino.write(f"{user_id}\n".encode())
        time.sleep(1)
        if arduino.in_waiting > 0:
            response = arduino.readline().decode().strip()
            print("response inside while loop : ", response)
            if response == "registration_success":
                print(f"Fingerprint for User ID: {user_id} successfully registered.")
                return True  # Indicate successful registration
            elif response == "registration_failed":
                print("Fingerprint registration failed. Retrying...")
                continue
    return False
	
def clear_users():
	arduino.write("clear_all_users\n".encode())
	time.sleep(1)
	if arduino.in_waiting>0:
		response = arduino.readline().decode().strip()
		print(response)
	
def verify_fingerprint():
	while True:
		arduino.write("verify\n".encode())  # Command Arduino to start fingerprint verification
		time.sleep(1)
		
		if arduino.in_waiting > 0:
			user_id = arduino.readline().decode().strip()
			print(user_id)
			if user_id.isnumeric():
				print(f"Fingerprint matched for User ID: {user_id}")
				# Retrieve user data from Firebase to verify user ID
				user_data = database.child("users").child(user_id).get().val()
				
				if user_data:
					if user_data.get("voted") == False:
						print(f"User {user_id} verified. Ready to vote.")
						return user_id  # Return verified user ID to allow voting
					else:
						print(f"User {user_id} has already voted.")
				else:
					print("User ID not found in Firebase.")

try:
	while True:
		register_request = database.child("users/register").get().val()
		if register_request == "true":
            # Retrieve user ID and name from Firebase
			user_id = database.child("users/next_user_id").get().val()
			user_name = database.child("users/next_user_name").get().val()

			if user_id and user_name:
				if arduino_register_command(user_id):  # Enroll fingerprint first
                    # After successful fingerprint registration, set user details in Firebase
					register_user_to_firebase(user_id, user_name)
					database.child("users/register").set("false")
					print("Registration complete.")
				else:
					print("Fingerprint registration unsuccessful. Aborting...")
			else:
				print("User ID or Name missing in Firebase.")
        
		time.sleep(5)
		voting_status = database.child("voting_status").get().val()
		if voting_status == "true":
			print("Verifying fingerprint...")
			user_id = verify_fingerprint()
			print(f"the user id is {user_id}")
			if user_id:
                # Allow voting for this user in Firebase
				database.child("current_user").set(user_id)
				database.child("voting_status").set("ready")

		clear = database.child("arduino_command").get().val()
		if clear:
			clear_users()
			database.child("arduino_command").remove()
        
		time.sleep(5)

except KeyboardInterrupt:
    print("Exit.")
    arduino.close()
