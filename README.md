## 설명
- 주류 설문 조사 앱

## API
Postman의 목업 서버를 사용하여 구현함
https://512ab7c7-e29e-4a64-ace6-d1e98a5ce40f.mock.pstmn.io/api/question/common 기본 설문조사 질문

json 형식
```json
{
    "status": 200,
    "data": {
        "forms": [
            {
                "name": "name",
                "question": "이름을 입력해주세요.",
                "required": true,
                "type": "text",
                "placeholder": "이름",
                "validate": [
                    {
                        "type": "not",
                        "target": "",
                        "validateText": "이름을 입력해주세요."
                    },
                    {
                        "type": "minMaxLength",
                        "target": [2, "-"],
                        "validateText": "이름을 2글자 이상 입력해주세요."
                    }
                ]
            },
            {
                "name": "email",
                "question": "이메일을 입력해주세요.",
                "required": true,
                "type": "text",
                "placeholder": "000@gmail.com",
                "validate": [
                    {
                        "type": "not",
                        "target": "",
                        "validateText": "이메일을 입력해주세요."
                    },
                    {
                        "type": "pattern",
                        "target": "^([\\w\\.\\_\\-])*[a-zA-Z0-9]+([\\w\\.\\_\\-])*([a-zA-Z0-9])+([\\w\\.\\_\\-])+@([a-zA-Z0-9]+\\.)+[a-zA-Z0-9]{2,8}$",
                        "validateText": "이메일 주소 형식이 올바르지 않습니다."
                    }
                ]
            },
            {
                "name": "age",
                "question": "나이를 입력해주세요.",
                "required": true,
                "type": "number",
                "placeholder": 0,
                "validate": [
                    {
                        "type": "not",
                        "target": 0,
                        "validateText": "나이를 입력해주세요."
                    }
                ]
            },
            {
                "name": "like",
                "question": "술을 얼마나 좋아하십니까?",
                "required": true,
                "type": "radioNumber",
                "placeholder": 0,
                "validate": [

                ]
            }
        ],
        "escapeValidate": [
            {
               "name": "age",
               "type": "minMax",
               "target": [19, "-"]
            }
        ]
    }
}
```

## 
