from dataclasses import dataclass
from datetime import date, datetime

@dataclass
class Member:
    id: int
    name: str
    email: str
    tall: float
    birthday: date
    created_at: datetime = datetime.now()