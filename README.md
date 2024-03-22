

## 설명
- 주류 설문 조사 앱   
서버에서 설문조사에 필요한 정보를 받아와 정보를 토대로 UI를 그리고 입력 폼에 따라 알맞은 Validation을 통해 입력한 내용을 서버에 보내주는 설문조사 앱입니다.    
Server Driven UI를 구현을 위해 제작


## 시현 영상
<img src="https://github.com/three523/Subvey_mission/assets/71269216/4dcfb9fb-4b1a-4ffd-a2c8-29795dc01fa4" width="250" height="400"/>

## 로직
```mermaid
sequenceDiagram
  participant VM as QuesionViewModel
  participant VC as ViewController   
  participant QV as QuestionView
  
  VC ->> VM: 설문 내용 요청
  note left of VM: 서버에 데이터 요청
  loop 
    VM ->> VC: 질문 폼 전달 , 실패시 에러 전달 및 에러뷰 띄우기
    VC ->> QV: 전달 받은 폼 전달
    note right of QV: 사용자가 다음 버튼 클릭시 Validation 체크
    QV --> VC: Validation 성공시 VC에게 설문 응답 전달
    VC --> VM: Form 질문 대답 내용 전달
    note left of VM: 질문내용 저장
    break 만약 질문이 없을 경우
      note left of VM: 총 질문 대답 서버에 전달, 다음 설문이 필요한 경우 새로운 설문 요청
    end 
  end
```

## API
Postman의 목업 서버를 사용하여 구현함   
[기본설문조사 API URL](https://512ab7c7-e29e-4a64-ace6-d1e98a5ce40f.mock.pstmn.io/api/question/common)

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

## 구현
각 Form에 맞는 View안에 Validation이 맞는지 체크하는 클래스를 배열로 만들어두고 다음 질문 버튼 클릭시 모든 유효성 검사를 실행하도록 구현

