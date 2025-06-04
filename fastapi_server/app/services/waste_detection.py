import asyncio
import base64
import io
from typing import Dict, Any, Set
from PIL import Image
from inference_sdk import InferenceHTTPClient
from app.core.config import settings
from app.core.logging import logger


class WasteDetectionService:
    def __init__(self):
        self.client = InferenceHTTPClient(
            api_url=settings.ROBOFLOW_MODEL_URL, api_key=settings.ROBOFLOW_API_KEY
        )
        self.model_id = settings.ROBOFLOW_MODEL_ID
        self.connected_clients: Set = set()

    async def add_client(self, websocket):
        """Add a new WebSocket client"""
        self.connected_clients.add(websocket)
        logger.info(
            f"WebSocket client connected. Total clients: {len(self.connected_clients)}"
        )

    async def remove_client(self, websocket):
        """Remove a WebSocket client"""
        self.connected_clients.discard(websocket)
        logger.info(
            f"WebSocket client disconnected. Total clients: {len(self.connected_clients)}"
        )

    def process_image_from_base64(self, base64_image: str) -> Image.Image:
        """Convert base64 image to PIL Image"""
        try:
            # Remove data URL prefix if present
            if "data:image" in base64_image:
                base64_image = base64_image.split(",")[1]

            # Decode base64 and create PIL Image
            image_data = base64.b64decode(base64_image)
            image = Image.open(io.BytesIO(image_data))

            # Convert to RGB if necessary
            if image.mode != "RGB":
                image = image.convert("RGB")

            return image
        except Exception as e:
            logger.error(f"Error processing image: {e}")
            raise ValueError(f"Failed to process image: {str(e)}")

    async def run_inference(self, image: Image.Image) -> Dict[str, Any]:
        """Run inference on the PIL Image directly"""
        try:
            # Run inference in thread pool to avoid blocking
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(
                None, lambda: self.client.infer(image, model_id=self.model_id)
            )

            # Ensure result is a dictionary
            if isinstance(result, list):
                return {"predictions": result}
            elif isinstance(result, dict):
                return result
            else:
                return {"predictions": []}

        except Exception as e:
            logger.error(f"Inference error: {e}")
            raise RuntimeError(f"Inference failed: {str(e)}")

    def format_detection_results(
        self, inference_result: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Format inference results for Flutter client"""
        try:
            predictions = inference_result.get("predictions", [])

            formatted_results = []
            for pred in predictions:
                result = {
                    "class": pred.get("class", "unknown"),
                    "confidence": round(pred.get("confidence", 0.0), 3),
                    "bbox": {
                        "x": pred.get("x", 0),
                        "y": pred.get("y", 0),
                        "width": pred.get("width", 0),
                        "height": pred.get("height", 0),
                    },
                }
                formatted_results.append(result)

            return {
                "success": True,
                "detections": formatted_results,
                "count": len(formatted_results),
                "timestamp": asyncio.get_event_loop().time(),
            }
        except Exception as e:
            logger.error(f"Error formatting results: {e}")
            return {"success": False, "error": str(e), "detections": [], "count": 0}

    async def process_detection_request(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Process a detection request"""
        try:
            base64_image = data.get("image")
            if not base64_image:
                raise ValueError("No image provided in request")

            # Process image
            image = self.process_image_from_base64(base64_image)

            # Run inference directly on PIL Image
            inference_result = await self.run_inference(image)

            # Format and return results
            formatted_result = self.format_detection_results(inference_result)

            return {"type": "detection_result", "data": formatted_result}

        except Exception as e:
            logger.error(f"Error processing detection request: {e}")
            return {"type": "error", "message": str(e)}


# Global service instance
waste_detection_service = WasteDetectionService()
