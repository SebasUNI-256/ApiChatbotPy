from typing import Any

from app.domain.entities import ChatResponse


def response_to_dict(response: ChatResponse) -> dict[str, Any]:
    payload = {
        "resultCode": response.result_code,
        "resultMessage": response.result_message,
        "rule": response.rule,
        "reply": response.reply,
        "products": response.products,
        "data": response.data,
    }
    if response.conversation_id is not None:
        payload["conversationId"] = response.conversation_id
    if response.page_number is not None:
        payload["pageNumber"] = response.page_number
        payload["pageSize"] = response.page_size
        payload["totalRows"] = response.total_rows
    return payload
