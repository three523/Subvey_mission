### 0. 모든 요청은 `?lang=en`으로 한/영을 표시할 수 있고, lang을 사용하지 않으면 default로 'ko'를 사용한다.

### 1. `/api/question/:typeID?lang=en`
- `GET` 요청
- typeID를 통해 유저에게 입력 받아야하는 form과 질문지를 받는다.
- response
```
{
    status: number;
    data: {
        forms: {
            name: string; // form 작성 후 서버에 보낼 때의 이름
            question: string; // user에게 보여줘야 하는 질문
            required: boolean; // 필수 질문 여부
            type: "text" | "number" | "checkbox" | "radio" | "radioNumber" | "radioWithInput" // form type;
            placeholder: string | number | boolean | {
                label: string;
                value: string;
                checked: boolean;
            }[]; // user가 선택 전 default로 선택된 value;
            validate: {
                type: 'not' | 'minMax' | 'sameAS' | 'pattern' | 'minMaxLength;
                target: number | [min, max] | `$name` | string;
                validateText: string;
            }[];
        }[];
        escapeValidate: {
            name: string;
            type: 'not' | 'minMax' | 'sameAS' | 'pattern' | 'minMaxLength;
            target: number | [min, max] | `$name` | string;
        }[]; // if name에 해당하는 value가 있고, 해당 validate를 통과하지 못하면 `no_target`으로 리다이렉트 시킨다.
    }
}
```
- type: `text` : text input 창 사용. placeholder: ''.
- type: `number` : number input 창 사용. placeholder: 0.
- type: `checkbox`: checkbox 선택 사용. placeholder: {
                label: string;
                value: string;
                checked: boolean;
            }[]; 
            -> label: 화면에 표시되는 text,
               value: 서버에 전송할 때의 값, 
               checked: default로 선택됨 여부
- type: `radio`: radio 선택 사용 placeholder: {
                label: string;
                value: string;
                checked: boolean;
            }[]; 
            -> label: 화면에 표시되는 text,
               value: 서버에 전송할 때의 값, 
               checked: default로 선택됨 여부
- type: `radioNumber`: radio로 표시된 점수 박스 사용(1~7점) 
            placeholder: {
                label: string;
                value: string;
                checked: boolean;
            }[]; 
            -> label: 화면에 표시되는 text,
               value: 서버에 전송할 때의 값, 
               checked: default로 선택됨 여부
- type: `radioWithInput`: radio 선택 + 기타 선택시 input으로 값을 입력받음. 만약 기타 입력 시 value에 사용자가 입력한 값을 서버로 전송함.
            placeholder: {
                label: string;
                value: string;
                checked: boolean;
            }[]; 
            -> label: 화면에 표시되는 text,
               value: 서버에 전송할 때의 값, 
               checked: default로 선택됨 여부

- validate type 설명
1. not: 해당 value가 target이면 안된다는 뜻.
```js
// ex 1
{
    type: 'not';
    target: '', -> 해당 value가 ''이면 안된다는 뜻.
}

// ex 2
{
    type: 'not';
    target: -1 -> 해당 value가 -1이면 안된다는 뜻.
}

// ex3
{
    type: 'not';
    target: [] -> 해당 value가 빈 array면 안된다는 뜻.
}

```
2. minMax: 해당 value가 target안에 들어야함.
'-' 표시는 제한이 없다는 뜻.
```js
// ex 1
{
    type: 'minMax';
    target: ['-', 3], -> 해당 value가 3 이하여야함.
}

// ex 2
{
    type: 'minMax';
    target: [19, '-'] -> 해당 value가 19 이상 이어야함.
}

// ex3
{
    type: 'minMax';
    target: [3, 3] -> 해당 value가 3이어야함.
}
```

3. sameAS: 해당 value가 target과 같아야함.
'-' 표시는 제한이 없다는 뜻.
```js
// ex 1
{
    type: 'sameAS';
    target: '$age', -> 해당 value가 age라는 이름의 value와 같아야함
}

// ex 2
{
    type: 'sameAS';
    target: 22 -> 해당 value가 22와 같아야함.
}
```

4. pattern: 해당 value는 target의 regex를 통과해야함.
```js
// ex 1
{
    type: 'pattern';
    target: '/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/', -> 해당 value는 target의 regex를 통과해야함.
}
```

5. minMaxLength: 해당 value의 length가 target범위 내에 있어야함.
'-' 표시는 제한이 없다는 뜻.
```js
// ex 1
{
    type: 'minMaxLength';
    target: [3, 5] -> 해당 value의 length는 3이상 5 이하여야함.
    validateText: '3개 이상 5개 이하로 선택할 수 있습니다.'
}
```

### 2. `/api/answers/:typeID?lang=en`
- `POST` 요청
- request
```
{
    answers: {
        [name]: value,
    }
}
```
- response
```
{
    status: number;
    data: {
        isSuccess: boolean;
        nextTypeId?: string;
    }
}
```