import cv2
import numpy as np
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from insightface.app import FaceAnalysis
from pydantic import BaseModel
from typing import List, Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Face AI Service",
    description="Face detection and embedding extraction service using InsightFace",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize face analysis model
try:
    face_app = FaceAnalysis(name="buffalo_l")
    face_app.prepare(ctx_id=0, det_size=(640, 640))
    logger.info("Face analysis model loaded successfully")
except Exception as e:
    logger.error(f"Failed to load face analysis model: {e}")
    face_app = None


class CompareRequest(BaseModel):
    embedding1: List[float]
    embedding2: List[float]


class HealthResponse(BaseModel):
    status: str
    model_loaded: bool


def cosine_similarity(vec1: List[float], vec2: List[float]) -> float:
    """Calculate cosine similarity between two vectors."""
    arr1 = np.array(vec1)
    arr2 = np.array(vec2)
    
    dot_product = np.dot(arr1, arr2)
    norm1 = np.linalg.norm(arr1)
    norm2 = np.linalg.norm(arr2)
    
    if norm1 == 0 or norm2 == 0:
        return 0.0
    
    return float(dot_product / (norm1 * norm2))


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy" if face_app else "degraded",
        "model_loaded": face_app is not None
    }


@app.post("/face/analyze")
async def analyze_face(image: UploadFile = File(...)):
    """
    Analyze an uploaded image and extract face embedding.
    
    Returns:
        - success: bool - Whether face extraction succeeded
        - embedding: List[float] - 512-dimensional face embedding (if success)
        - error: str - Error message (if not success)
        - face_count: int - Number of faces detected
    """
    if face_app is None:
        raise HTTPException(status_code=503, detail="Face analysis model not loaded")
    
    try:
        # Read and decode image
        contents = await image.read()
        img = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(img, cv2.IMREAD_COLOR)
        
        if img is None:
            return {"success": False, "error": "Invalid image format", "face_count": 0}
        
        # Detect faces
        faces = face_app.get(img)
        
        if len(faces) == 0:
            return {"success": False, "error": "No face detected", "face_count": 0}
        
        if len(faces) > 1:
            return {"success": False, "error": "Multiple faces detected. Single face required.", "face_count": len(faces)}
        
        # Extract embedding
        embedding = faces[0].embedding.tolist()
        
        return {
            "success": True,
            "embedding": embedding,
            "face_count": 1
        }
        
    except Exception as e:
        logger.error(f"Error analyzing face: {e}")
        return {"success": False, "error": str(e), "face_count": 0}


@app.post("/face/compare")
async def compare_embeddings(request: CompareRequest):
    """
    Compare two face embeddings and return similarity score.
    
    Returns:
        - similarity: float - Cosine similarity score (0.0 to 1.0)
        - match: bool - Whether similarity exceeds threshold (0.80)
    """
    try:
        similarity = cosine_similarity(request.embedding1, request.embedding2)
        return {
            "similarity": round(similarity, 4),
            "match": similarity > 0.80
        }
    except Exception as e:
        logger.error(f"Error comparing embeddings: {e}")
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/face/analyze_multiple")
async def analyze_multiple_faces(image: UploadFile = File(...)):
    """
    Analyze an uploaded image and extract embeddings for all detected faces.
    
    Returns:
        - success: bool
        - faces: List of face data with embeddings and bounding boxes
        - face_count: int
    """
    if face_app is None:
        raise HTTPException(status_code=503, detail="Face analysis model not loaded")
    
    try:
        contents = await image.read()
        img = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(img, cv2.IMREAD_COLOR)
        
        if img is None:
            return {"success": False, "error": "Invalid image format", "faces": [], "face_count": 0}
        
        faces = face_app.get(img)
        
        if len(faces) == 0:
            return {"success": False, "error": "No faces detected", "faces": [], "face_count": 0}
        
        face_data = []
        for i, face in enumerate(faces):
            face_data.append({
                "index": i,
                "embedding": face.embedding.tolist(),
                "bbox": face.bbox.tolist() if hasattr(face, 'bbox') else None,
                "det_score": float(face.det_score) if hasattr(face, 'det_score') else None
            })
        
        return {
            "success": True,
            "faces": face_data,
            "face_count": len(faces)
        }
        
    except Exception as e:
        logger.error(f"Error analyzing multiple faces: {e}")
        return {"success": False, "error": str(e), "faces": [], "face_count": 0}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
