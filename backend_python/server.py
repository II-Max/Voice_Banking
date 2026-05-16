from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Cấu hình CORS để Flutter Client có thể gọi API mà không bị chặn
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class VoiceRequest(BaseModel):
    text: str

@app.post("/api/voice-banking")
async def process_voice_command(data: VoiceRequest):
    user_command = data.text.lower()
    response_message = ""
    
    # Bộ phân tích luật (Rule-based) đơn giản để chạy DEMO mượt mà
    if "số dư" in user_command or "tài khoản" in user_command:
        response_message = "Số dư khả dụng trong tài khoản của cậu là 50.000.000 VND."
    elif "chuyển" in user_command:
        # Ví dụ: "Chuyển tiền cho mẹ" hay "Chuyển 1 triệu"
        response_message = "Hệ thống đã nhận lệnh chuyển khoản. Vui lòng xác nhận thông tin trên màn hình."
    elif "lịch sử" in user_command or "giao dịch" in user_command:
        response_message = "Đây là lịch sử 3 giao dịch gần nhất của cậu."
    else:
        response_message = "Tôi đã ghi nhận yêu cầu, nhưng tính năng này đang được cập nhật."

    return {"response": response_message}

if __name__ == "__main__":
    import uvicorn
    # Chạy server ở cổng 8000
    uvicorn.run(app, host="0.0.0.0", port=8000)