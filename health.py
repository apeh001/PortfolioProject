from fastapi import FastAPI, HTTPException

app = FastAPI()

users = []

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/users")
def get_users():
    return users

@app.post("/users")
def create_user(user: dict):
    if "name" not in user:
        raise HTTPException(status_code = 400, detail = "name required")
    
    users.append(user)
    return user
