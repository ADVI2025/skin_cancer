# Skin Cancer Detection App

A mobile application built with Flutter that uses a MobileViT-based deep learning model to classify skin lesions as **benign** or **malignant**. The model runs locally on-device using TensorFlow Lite, ensuring both performance and user privacy.

---

## Features

- AI-powered skin lesion classification (benign or malignant)
- Image selection from gallery
- On-device prediction using TensorFlow Lite
- Displays prediction label and confidence score
- Lightweight and privacy-friendly — no server interaction required

---

## Tech Stack

- **Flutter** – Cross-platform mobile UI
- **TensorFlow Lite** – On-device model inference
- **PyTorch + MobileViT** – Model architecture and training
- **ONNX + TensorFlow** – Model conversion pipeline

---

## Model Overview

| Property        | Details                     |
|----------------|-----------------------------|
| Model           | MobileViT-S (small)         |
| Input Size      | 224x224 RGB image           |
| Output Classes  | 2 (`benign`, `malignant`)   |
| Framework       | Trained in PyTorch          |
| Deployment      | Converted to `.tflite`      |

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ADVI2025/skin_cancer.git
cd skin_cancer
