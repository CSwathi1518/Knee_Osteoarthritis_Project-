import cv2
import numpy as np
import matplotlib.pyplot as plt

# Load the image
image_path = '/mnt/data/1l.png'
image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Preprocess the image if needed (e.g., apply filters, thresholding)
blurred = cv2.GaussianBlur(image, (5, 5), 0)
_, binary_image = cv2.threshold(blurred, 50, 255, cv2.THRESH_BINARY)

# Find contours
contours, _ = cv2.findContours(binary_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Assume the largest contour is the region of interest
roi_contour = max(contours, key=cv2.contourArea)

# Draw the contour on the original image
image_with_contour = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
cv2.drawContours(image_with_contour, [roi_contour], -1, (0, 255, 0), 2)

# Approximate the contour to a polygon to find the region of interest
epsilon = 0.02 * cv2.arcLength(roi_contour, True)
approx = cv2.approxPolyDP(roi_contour, epsilon, True)

# Calculate the bounding box of the region of interest
x, y, w, h = cv2.boundingRect(approx)

# Extract the region of interest from the image
roi = image[y:y+h, x:x+w]

# Measure the JSW in the ROI
# Assuming the JSW is the minimum distance between the upper and lower edges
def measure_jsw(roi):
    # Find edges
    edges = cv2.Canny(roi, 50, 150)
    
    # Find contours in the ROI
    roi_contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Find the top and bottom edges of the joint space
    if len(roi_contours) >= 2:
        top_edge = min(roi_contours, key=lambda c: cv2.boundingRect(c)[1])
        bottom_edge = max(roi_contours, key=lambda c: cv2.boundingRect(c)[1] + cv2.boundingRect(c)[3])
        
        # Measure the distance between the top and bottom edges
        top_y = cv2.boundingRect(top_edge)[1]
        bottom_y = cv2.boundingRect(bottom_edge)[1] + cv2.boundingRect(bottom_edge)[3]
        
        jsw = bottom_y - top_y
        return jsw
    else:
        return None

jsw = measure_jsw(roi)
if jsw is not None:
    print(f"Joint Space Width (JSW): {jsw} pixels")
else:
    print("Could not measure JSW")

# Display the images
plt.figure(figsize=(10, 5))
plt.subplot(1, 2, 1)
plt.title('Original Image with Contour')
plt.imshow(cv2.cvtColor(image_with_contour, cv2.COLOR_BGR2RGB))
plt.subplot(1, 2, 2)
plt.title('Region of Interest')
plt.imshow(roi, cmap='gray')
plt.show()

pixel_to_mm = 0.1  # example conversion factor
if jsw is not None:
    jsw_mm = jsw * pixel_to_mm
    print(f"Joint Space Width (JSW): {jsw_mm:.2f} mm")  # Display JSW in mm with 2 decimal places
else:
    print("Could not measure JSW in mm")
