import json
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.services.waste_detection import waste_detection_service
from app.core.logging import logger

websocket_router = APIRouter()


@websocket_router.websocket("/detect")
async def websocket_waste_detection(websocket: WebSocket):
    """WebSocket endpoint for real-time waste detection"""
    await websocket.accept()
    await waste_detection_service.add_client(websocket)

    try:
        # Send welcome message
        await websocket.send_text(
            json.dumps(
                {
                    "type": "connected",
                    "message": "Connected to waste classification live server",
                }
            )
        )

        # Handle incoming messages
        while True:
            try:
                # Receive message with timeout
                message = await asyncio.wait_for(websocket.receive_text(), timeout=30.0)

                # Parse message
                try:
                    data = json.loads(message)
                except json.JSONDecodeError:
                    await websocket.send_text(
                        json.dumps({"type": "error", "message": "Invalid JSON format"})
                    )
                    continue

                message_type = data.get("type")

                if message_type == "detect":
                    # Process detection request
                    response = await waste_detection_service.process_detection_request(
                        data
                    )
                    await websocket.send_text(json.dumps(response))

                elif message_type == "ping":
                    # Health check
                    await websocket.send_text(
                        json.dumps(
                            {
                                "type": "pong",
                                "timestamp": asyncio.get_event_loop().time(),
                            }
                        )
                    )

                else:
                    await websocket.send_text(
                        json.dumps(
                            {
                                "type": "error",
                                "message": f"Unknown message type: {message_type}",
                            }
                        )
                    )

            except asyncio.TimeoutError:
                # Send ping to check connection
                await websocket.send_text(
                    json.dumps(
                        {"type": "ping", "timestamp": asyncio.get_event_loop().time()}
                    )
                )

    except WebSocketDisconnect:
        logger.info("WebSocket client disconnected normally")
    except Exception as e:
        logger.error(f"Error in WebSocket connection: {e}", exc_info=True)
    finally:
        await waste_detection_service.remove_client(websocket)


@websocket_router.websocket("/test")
async def websocket_test(websocket: WebSocket):
    """Test WebSocket endpoint"""
    await websocket.accept()

    try:
        await websocket.send_text(
            json.dumps(
                {
                    "type": "connected",
                    "message": "Test WebSocket connection established",
                }
            )
        )

        while True:
            message = await websocket.receive_text()
            await websocket.send_text(
                json.dumps(
                    {
                        "type": "echo",
                        "message": f"Echo: {message}",
                        "timestamp": asyncio.get_event_loop().time(),
                    }
                )
            )

    except WebSocketDisconnect:
        logger.info("Test WebSocket disconnected")
    except Exception as e:
        logger.error(f"Error in test WebSocket: {e}")
