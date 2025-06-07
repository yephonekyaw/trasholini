import base64
from datetime import datetime
import io
import mimetypes
import uuid
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, Form, HTTPException, Request, UploadFile, File
from pydantic import BaseModel
from google import genai
from app.utils.storage import storage_client
from PIL import Image

from app.utils.extract_user_id import get_user_id
from app.utils.firestore import firestore_client
from app.services.waste_detection import waste_detection_service
from app.core.config import settings
from app.core.logging import logger
from google.cloud.firestore import FieldFilter

scan_router = APIRouter()

# Configure Gemini API
client = genai.Client(api_key=settings.GEMINI_API_KEY)


class ScanRequest(BaseModel):
    image: str  # base64 encoded image


class ScanResponse(BaseModel):
    success: bool
    waste_class: str
    confidence: float
    disposal_tips: str
    recommended_bin: Dict[str, Any]
    message: str


class DisposalTip(BaseModel):
    bin_id: str
    bin_name: str
    bin_description: str
    tips: str
    is_recommended: bool


# Available bins information for prompt context
AVAILABLE_BINS = {
    "IAwm6VLUto6hIHKg2p2U": {"name": "Blue Bin", "description": "Recyclable Waste"},
    "JWU85wViqZWpwa06T2Gp": {"name": "Red Bin", "description": "Hazardous Waste"},
    "YEyKfXmPrwV9rT6PGvWi": {"name": "Grey Bin", "description": "Residual Waste"},
    "nnqLrEKtFYwN32rYyFpN": {"name": "Yellow Bin", "description": "Inorganic Waste"},
    "swBByWbqLGZPDpQr0WbJ": {"name": "Green Bin", "description": "Green Waste"},
}


async def upload_image_to_gcs(
    file: UploadFile, user_id: str, bucket_name: str = ""
) -> str:
    """
    Upload image to Google Cloud Storage and return public URL
    """
    try:
        # Use default bucket name if not provided
        if not bucket_name:
            bucket_name = settings.GCS_BUCKET_NAME

        logger.info(f"Uploading image to GCS bucket: {bucket_name}")

        # Read file content
        file_content = await file.read()

        # Reset file pointer
        await file.seek(0)

        # Generate unique filename
        file_extension = ""
        if file.filename:
            file_extension = (
                file.filename.split(".")[-1] if "." in file.filename else "jpg"
            )
        else:
            file_extension = "jpg"

        # Create unique filename: disposal-images/{user_id}/{timestamp}_{uuid}.{extension}
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        blob_name = (
            f"disposal-images/{user_id}/{timestamp}_{unique_id}.{file_extension}"
        )

        logger.info(f"Generated blob name: {blob_name}")

        # Get bucket and create blob
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)

        # Set content type
        content_type = file.content_type or f"image/{file_extension}"
        blob.content_type = content_type

        # Upload file
        blob.upload_from_string(file_content, content_type=content_type)

        # Make the blob publicly accessible
        blob.make_public()

        # Get public URL
        public_url = blob.public_url

        logger.info(f"Image uploaded successfully. Public URL: {public_url}")

        return public_url

    except Exception as e:
        logger.error(f"Error uploading image to GCS: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {str(e)}")


def is_valid_image_file(file: UploadFile) -> bool:
    """
    Enhanced image file validation that checks multiple indicators
    """
    try:
        # Check 1: File extension
        if file.filename:
            filename_lower = file.filename.lower()
            valid_extensions = [
                ".jpg",
                ".jpeg",
                ".png",
                ".gif",
                ".bmp",
                ".tiff",
                ".webp",
            ]
            has_valid_extension = any(
                filename_lower.endswith(ext) for ext in valid_extensions
            )

            if has_valid_extension:
                logger.info(f"File has valid image extension: {file.filename}")
                return True

        # Check 2: MIME type (if provided and reliable)
        if file.content_type and file.content_type.startswith("image/"):
            logger.info(f"File has valid MIME type: {file.content_type}")
            return True

        # Check 3: Guess MIME type from filename
        if file.filename:
            guessed_type, _ = mimetypes.guess_type(file.filename)
            if guessed_type and guessed_type.startswith("image/"):
                logger.info(f"Guessed valid MIME type: {guessed_type}")
                return True

        # Log what we found for debugging
        logger.warning(f"File validation details:")
        logger.warning(f"  - Filename: {file.filename}")
        logger.warning(f"  - Content-Type: {file.content_type}")
        logger.warning(
            f"  - Guessed type: {mimetypes.guess_type(file.filename or '') if file.filename else 'N/A'}"
        )

        return False

    except Exception as e:
        logger.error(f"Error validating image file: {e}")
        return False


def validate_image_content(file_content: bytes) -> bool:
    """
    Validate that the file content is actually a valid image by trying to open it
    """
    try:
        image = Image.open(io.BytesIO(file_content))
        # Try to verify the image
        image.verify()
        logger.info(f"Image content validation successful: {image.format} {image.size}")
        return True
    except Exception as e:
        logger.warning(f"Image content validation failed: {e}")
        return False


async def get_user_available_bins(user_id: str) -> List[str]:
    """Get list of bin IDs that user has access to"""
    try:
        doc_ref = firestore_client.collection("available-bins").document(user_id)
        doc = doc_ref.get()

        if not doc.exists:
            logger.info(
                f"No bin preferences found for user {user_id}, returning all bins"
            )
            return list(AVAILABLE_BINS.keys())

        doc_data = doc.to_dict()
        if doc_data is None:
            return list(AVAILABLE_BINS.keys())

        accessible_bins = doc_data.get("bin_ids", [])
        return accessible_bins if accessible_bins else list(AVAILABLE_BINS.keys())

    except Exception as e:
        logger.error(f"Error getting user accessible bins: {str(e)}")
        return list(AVAILABLE_BINS.keys())


def create_disposal_prompt(waste_class: str, user_bins: List[str]) -> str:
    """Create prompt for Gemini API to get disposal tips"""
    user_bin_info = []
    for bin_id in user_bins:
        if bin_id in AVAILABLE_BINS:
            bin_data = AVAILABLE_BINS[bin_id]
            user_bin_info.append(
                f"- {bin_data['name']} ({bin_id}): {bin_data['description']}"
            )

    bins_text = "\n".join(user_bin_info)

    prompt = f"""
You are an expert waste management advisor. A user has scanned a waste item and our AI has classified it as: "{waste_class}".

The user has access to the following waste bins:
{bins_text}

Please provide:
1. The most appropriate bin for disposing this "{waste_class}" item
2. Specific disposal tips and instructions for this item type
3. Any preparation steps needed before disposal (cleaning, removing parts, etc.)
4. Environmental impact or recycling information if relevant

Please respond in JSON format with the following structure:
{{
    "recommended_bin_id": "bin_id_here",
    "disposal_tips": "detailed disposal instructions here",
    "preparation_steps": "any preparation needed before disposal",
    "environmental_note": "brief environmental impact or benefit note"
}}

Be concise but informative. Focus on practical, actionable advice.
    """
    return prompt


async def get_disposal_tips_from_gemini(
    waste_class: str, user_bins: List[str]
) -> Dict[str, Any]:
    """Get disposal tips from Gemini API"""
    try:
        prompt = create_disposal_prompt(waste_class, user_bins)

        response = client.models.generate_content(
            model="gemini-2.5-flash-preview-05-20",
            contents=prompt,
        )

        # Parse the JSON response
        import json

        try:
            response_text = response.text or ""
            tips_data = json.loads(response_text.strip())
            return tips_data
        except json.JSONDecodeError:
            # Fallback if JSON parsing fails
            return {
                "recommended_bin_id": (
                    user_bins[0] if user_bins else "YEyKfXmPrwV9rT6PGvWi"
                ),
                "disposal_tips": response.text,
                "preparation_steps": "Please clean the item before disposal",
                "environmental_note": "Proper disposal helps protect our environment",
            }

    except Exception as e:
        logger.error(f"Error getting disposal tips from Gemini: {str(e)}")
        # Fallback response
        return {
            "recommended_bin_id": user_bins[0] if user_bins else "YEyKfXmPrwV9rT6PGvWi",
            "disposal_tips": f"Please dispose of this {waste_class} item in the appropriate bin based on your local waste management guidelines.",
            "preparation_steps": "Clean the item if necessary before disposal",
            "environmental_note": "Proper waste disposal helps protect our environment",
        }


@scan_router.post("/save-tips", response_model=Dict[str, Any])
async def save_disposal_tips(
    request: Request,
    file: UploadFile = File(...),
    waste_class: str = Form(...),
    confidence: str = Form(...),
    disposal_tips: str = Form(...),
    preparation_steps: str = Form(...),
    environmental_note: str = Form(...),
    message: str = Form(...),
    recommended_bin_id: Optional[str] = Form(None),
    recommended_bin_name: Optional[str] = Form(None),
    recommended_bin_description: Optional[str] = Form(None),
):
    """
    Save disposal tips with image to user's history
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Saving disposal tips for user: {user_id}")

        # Validate the uploaded file
        if not is_valid_image_file(file):
            logger.warning(f"File validation failed for: {file.filename}")
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Please upload an image file. Received: {file.content_type}",
            )

        # Read file content for validation
        file_content = await file.read()

        # Validate image content
        if not validate_image_content(file_content):
            logger.warning(f"Image content validation failed for: {file.filename}")
            raise HTTPException(
                status_code=400, detail="File is not a valid image or is corrupted"
            )

        # Reset file pointer for upload
        await file.seek(0)

        # Upload image to Google Cloud Storage
        try:
            image_url = await upload_image_to_gcs(file, user_id)
            logger.info(f"Image uploaded successfully: {image_url}")
        except HTTPException:
            raise
        except Exception as upload_error:
            logger.error(f"Failed to upload image: {upload_error}")
            raise HTTPException(
                status_code=500, detail="Failed to upload image to cloud storage"
            )

        # Create disposal history record
        current_time = datetime.now()

        # Prepare disposal history data
        disposal_record = {
            "user_id": user_id,
            "waste_class": waste_class,
            "confidence": float(confidence),
            "disposal_tips": disposal_tips,
            "preparation_steps": preparation_steps,
            "environmental_note": environmental_note,
            "message": message,
            "recommended_bin": (
                {
                    "id": recommended_bin_id,
                    "name": recommended_bin_name,
                    "description": recommended_bin_description,
                }
                if recommended_bin_id
                else None
            ),
            "image_url": image_url,  # Changed from image_filename to image_url
            "image_filename": file.filename,  # Keep original filename for reference
            "created_at": current_time,
            "saved_at": current_time.isoformat(),
        }

        # Save to Firestore disposal-history collection
        try:
            disposal_collection = firestore_client.collection("disposal-history")
            doc_ref = disposal_collection.add(disposal_record)

            logger.info(f"Disposal tips saved with ID: {doc_ref[1].id}")

            # Update user's profile with eco points and scan count
            try:
                profiles_ref = firestore_client.collection("profiles")
                user_query = profiles_ref.where(
                    filter=FieldFilter("user_id", "==", user_id)
                ).limit(1)
                user_docs = list(user_query.stream())

                if user_docs:
                    user_doc = user_docs[0]
                    current_data = user_doc.to_dict() or {}

                    # Award 5 points for saving tips
                    new_eco_points = current_data.get("eco_points", 0) + 10
                    new_total_scans = current_data.get("total_scans", 0) + 1

                    user_doc.reference.update(
                        {
                            "eco_points": new_eco_points,
                            "total_scans": new_total_scans,
                            "updated_at": current_time,
                        }
                    )

                    logger.info(
                        f"Updated user {user_id}: eco_points={new_eco_points}, total_scans={new_total_scans}"
                    )

            except Exception as profile_error:
                logger.warning(f"Failed to update user profile: {profile_error}")
                # Don't fail the whole request if profile update fails

            return {
                "success": True,
                "message": "Tips saved successfully to your history!",
                "disposal_id": doc_ref[1].id,
                "image_url": image_url,
                "eco_points_earned": 5,
                "saved_at": current_time.isoformat(),
            }

        except Exception as firestore_error:
            logger.error(f"Failed to save to Firestore: {firestore_error}")
            raise HTTPException(
                status_code=500, detail="Failed to save disposal tips to database"
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error saving disposal tips: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to save disposal tips")


@scan_router.post("/analyze", response_model=ScanResponse)
async def analyze_waste_item(scan_data: ScanRequest, request: Request):
    """
    Analyze waste item from base64 image and provide disposal tips
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Analyzing waste item for user: {user_id}")

        # Step 1: Get waste classification from existing detection service
        detection_data = {"type": "detect", "image": scan_data.image}

        detection_result = await waste_detection_service.process_detection_request(
            detection_data
        )

        if detection_result.get("type") == "error":
            raise HTTPException(
                status_code=400,
                detail=f"Waste detection failed: {detection_result.get('message')}",
            )

        # Extract detection results
        result_data = detection_result.get("data", {})
        detections = result_data.get("detections", [])

        if not detections:
            raise HTTPException(
                status_code=400, detail="No waste items detected in the image"
            )

        # Get the detection with highest confidence
        best_detection = max(detections, key=lambda x: x.get("confidence", 0))
        waste_class = best_detection.get("class", "unknown")
        confidence = best_detection.get("confidence", 0.0)

        logger.info(
            f"Detected waste class: {waste_class} with confidence: {confidence}"
        )

        # Step 2: Get user's available bins
        user_bins = await get_user_available_bins(user_id)
        logger.info(f"User {user_id} has access to bins: {user_bins}")

        # Step 3: Get disposal tips from Gemini
        disposal_info = await get_disposal_tips_from_gemini(waste_class, user_bins)

        # Step 4: Format response
        recommended_bin_id = disposal_info.get("recommended_bin_id")
        recommended_bin = None

        if recommended_bin_id and recommended_bin_id in AVAILABLE_BINS:
            recommended_bin = {
                "id": recommended_bin_id,
                "name": AVAILABLE_BINS[recommended_bin_id]["name"],
                "description": AVAILABLE_BINS[recommended_bin_id]["description"],
            }

        # Combine all disposal information
        disposal_tips = disposal_info.get("disposal_tips", "")
        preparation_steps = disposal_info.get("preparation_steps", "")
        environmental_note = disposal_info.get("environmental_note", "")

        full_tips = f"{disposal_tips}"
        if preparation_steps:
            full_tips += f"\n\nPreparation: {preparation_steps}"
        if environmental_note:
            full_tips += f"\n\nEnvironmental Note: {environmental_note}"

        return ScanResponse(
            success=True,
            waste_class=waste_class,
            confidence=confidence,
            disposal_tips=full_tips,
            recommended_bin=recommended_bin or {},
            message="Waste item analyzed successfully",
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing waste item: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Failed to analyze waste item: {str(e)}"
        )


@scan_router.post("/analyze-upload", response_model=ScanResponse)
async def analyze_waste_from_upload(request: Request, file: UploadFile = File(...)):
    """
    Analyze waste item from uploaded file
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Analyzing uploaded waste image for user: {user_id}")

        # Log file details for debugging
        logger.info(
            f"Received file: {file.filename}, size: {file.size}, type: {file.content_type}"
        )

        # Enhanced file validation
        if not is_valid_image_file(file):
            logger.warning(f"File validation failed for: {file.filename}")
            raise HTTPException(
                status_code=400,
                detail=f"Invalid file type. Please upload an image file. Received: {file.content_type}",
            )

        # Read file content
        try:
            image_data = await file.read()
            logger.info(f"Successfully read file content: {len(image_data)} bytes")
        except Exception as e:
            logger.error(f"Error reading file content: {e}")
            raise HTTPException(status_code=400, detail="Failed to read uploaded file")

        # Validate image content
        if not validate_image_content(image_data):
            logger.warning(f"Image content validation failed for: {file.filename}")
            raise HTTPException(
                status_code=400, detail="File is not a valid image or is corrupted"
            )

        # Process image
        try:
            image = Image.open(io.BytesIO(image_data))

            # Convert to RGB if necessary
            if image.mode != "RGB":
                logger.info(f"Converting image from {image.mode} to RGB")
                image = image.convert("RGB")

            logger.info(
                f"Image processed successfully: {image.size}, mode: {image.mode}"
            )
        except Exception as e:
            logger.error(f"Error processing image: {e}")
            raise HTTPException(status_code=400, detail="Failed to process image file")

        # Convert to base64 for detection service
        try:
            buffer = io.BytesIO()
            image.save(buffer, format="JPEG", quality=85)
            base64_image = base64.b64encode(buffer.getvalue()).decode()
            logger.info(f"Image converted to base64: {len(base64_image)} characters")
        except Exception as e:
            logger.error(f"Error converting image to base64: {e}")
            raise HTTPException(
                status_code=500, detail="Failed to convert image for processing"
            )

        # Create scan request and process
        scan_data = ScanRequest(image=base64_image)
        result = await analyze_waste_item(scan_data, request)

        logger.info(f"Analysis completed successfully for user: {user_id}")
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing uploaded waste image: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Failed to analyze uploaded image: {str(e)}"
        )


# Add a new endpoint to get user's disposal history
@scan_router.get("/disposal-history", response_model=Dict[str, Any])
async def get_disposal_history(request: Request, limit: int = 20):
    """
    Get user's disposal history
    """
    try:
        user_id = get_user_id(request)
        logger.info(f"Getting disposal history for user: {user_id}")

        # Query disposal history for the user
        disposal_collection = firestore_client.collection("disposal-history")
        query = (
            disposal_collection.where(filter=FieldFilter("user_id", "==", user_id))
            .order_by("created_at", direction="DESCENDING")
            .limit(limit)
        )

        docs = query.stream()

        history = []
        for doc in docs:
            doc_data = doc.to_dict()
            doc_data["id"] = doc.id  # Add document ID
            history.append(doc_data)

        return {
            "success": True,
            "history": history,
            "count": len(history),
            "message": f"Retrieved {len(history)} disposal records",
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting disposal history: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to get disposal history")


@scan_router.get("/supported-classes")
async def get_supported_waste_classes():
    """
    Get list of waste classes that can be detected
    """
    # This would typically come from your model's class list
    # For now, returning common waste categories
    return {
        "supported_classes": [
            "plastic_bottle",
            "glass_bottle",
            "aluminum_can",
            "paper",
            "cardboard",
            "food_waste",
            "electronic_waste",
            "battery",
            "textile",
            "metal",
            "general_waste",
        ],
        "total_classes": 11,
    }
