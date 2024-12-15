print('Starting MongoDB initialization...');

try {
    // Wait for MongoDB to be ready
    sleep(5000);

    // Switch to admin database
    db = db.getSiblingDB('admin');

    // Create root user if it doesn't exist
    if (!db.getUser(process.env.MONGODB_USER)) {
        db.createUser({
            user: process.env.MONGODB_USER,
            pwd: process.env.MONGODB_PASSWORD,
            roles: ['root']
        });
    }

    // Switch to langchain database
    db = db.getSiblingDB(process.env.MONGODB_DATABASE);

    // Create collections if they don't exist
    if (!db.getCollectionNames().includes('vectors')) {
        db.createCollection('vectors');
        print('Created vectors collection');
    }

    // Create vector search index
    db.vectors.createIndex(
        {
            "embedding": {
                "type": "vectorSearch",
                "numDimensions": 1536,
                "similarity": "cosine"
            }
        },
        {
            name: "vector_index"
        }
    );
    print('Created vector search index');

} catch (err) {
    print('Error during initialization: ' + err);
    throw err;
}

print('MongoDB initialization complete');