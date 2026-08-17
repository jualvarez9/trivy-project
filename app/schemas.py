from pydantic import BaseModel

class TaskCreate(BaseModel):
    title: str
    description: str | None = None
    priority: int | None = None

