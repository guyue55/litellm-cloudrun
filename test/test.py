# coding: utf-8
"""
测试 LiteLLM 调用模型
"""

import openai

client = openai.OpenAI(
    # 1. 你的 Cloud Run 域名 (注意结尾不要带 /v1/chat/completions，SDK 会自动补全)
    base_url="https://<YOUR-CLOUD-RUN-URL>", 
    
    # 2. 你的 Master Key (必须加 Bearer，SDK 会自动处理)
    api_key="sk-123456"
)

print("正在调用 via LiteLLM...")

try:
    response = client.chat.completions.create(
        model="gemini-3.0-pro-preview", # 必须匹配 config.yaml 里的 model_name
        messages=[
            {"role": "user", "content": "你好，请告诉我今天是几号？"}
        ]
    )
    print("回复内容：")
    print(response.choices[0].message.content)
    
except Exception as e:
    print(f"出错: {e}")