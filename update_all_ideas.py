from google.cloud import firestore

# Initialize Firestore client
db = firestore.Client()

# Constants for collections
cUsers = 'users'  # Replace with your actual collection name for users
cIdeas = 'ideas'  # Replace with your actual collection name for ideas

# Function to update isProcessingAudio field to False
def update_is_processing_audio():
    # Get all users (even if the users document doesn't exist, focus on ideas subcollection)
    users_ref = db.collection(cUsers)
    users = users_ref.list_documents()

    for user in users:
        user_id = user.id
        print(f'Processing user: {user_id}')

        # Get all ideas for the current user
        ideas_ref = user.collection(cIdeas)
        ideas = ideas_ref.stream()

        for idea in ideas:
            idea_id = idea.id
            print(f'Updating idea: {idea_id} for user: {user_id}')
            
            # Update the isProcessingAudio field to False
            idea_ref = ideas_ref.document(idea_id)
            idea_ref.update({'isProcessingAudio': False})

    print('Update complete.')

if __name__ == '__main__':
    update_is_processing_audio()
