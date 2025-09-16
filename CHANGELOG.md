# Changelog

All notable changes to the ZindeAI project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2024-09-16

### Added - Initial MVP Release
- **Flutter Project Bootstrap**: Complete Flutter project structure with proper dependencies
- **Core Models**: User and Meal data models with JSON serialization
- **Camera Service**: Photo capture and gallery selection functionality
- **Groq AI Integration**: Smart macro estimation using `gemma2-9b-it` model for Turkish cuisine
- **Firebase Integration**: 
  - Firestore for data storage (users and meals collections)
  - Firebase Storage for meal photos
  - Remote Config for secure API key management
- **Screen Components**:
  - Home Screen: Daily meal timeline with macro summaries
  - Camera Screen: Photo capture and AI analysis workflow
  - Profile Screen: User profile management with BMI calculation
- **Platform Support**: 
  - Android configuration with camera permissions
  - iOS configuration with camera and photo library permissions
- **Documentation**:
  - Comprehensive README with setup instructions
  - Project structure documentation
  - Cost structure and roadmap

### Technical Details
- **Dependencies**: Camera, image_picker, http, Firebase suite (core, firestore, storage, remote_config)
- **Architecture**: Clean service-based architecture with separation of concerns
- **AI Model**: Groq gemma2-9b-it for Turkish cuisine specialization
- **Target Platforms**: Android and iOS via Flutter
- **Minimum SDK**: Flutter >=3.3.0, Dart >=3.0.0

### MVP Scope
This release implements the core value proposition:
1. Take photo of food
2. Add description (user input)
3. Get AI macro estimation
4. Save to daily timeline
5. Track progress toward daily goals

### Future Roadmap
- v1.9: Barcode scanning, meal templates, water tracking
- v2.0: Vision models, advanced analytics, social features

## [Previous Versions]

### [v1.7.3] - 2024-09-16
- **Status**: Over-engineered version (deprecated)
- **Issues**: Unnecessary n8n proxy complexity, untested vision models, offline mode complexity

### [v1.7.2] - 2024-09-16
- **Focus**: Vision model experimentation
- **Result**: Moved away from this approach for MVP simplicity

### [v1.7.1] - 2024-09-16
- **Focus**: Reality check on technical constraints
- **Outcome**: Simplified to direct API approach

### [v1.7] - 2024-09-16
- **Focus**: n8n VPS integration with multi-model routing
- **Decision**: Delayed for post-MVP implementation

### [v1.6] - 2024-09-16
- **Focus**: Groq-optimized features
- **Result**: Foundation for current MVP approach

### [v1.5.1] - 2024-09-16
- **Focus**: Groq free tier analysis
- **Outcome**: Confirmed viability for MVP

### [v1.5] - 2024-09-16
- **Focus**: MVP feature definition
- **Result**: Core feature set established

### [Earlier Versions (v1.2 - v1.4)]
- **Focus**: Feature exploration and architecture planning
- **Outcome**: Led to simplified MVP approach in v1.8

---

## Version History Summary

The ZindeAI project evolved through multiple iterations to arrive at the current MVP v1.8:

- **v1.2-v1.4**: Initial feature exploration and over-engineering
- **v1.5-v1.7**: Technical reality checks and simplification
- **v1.8**: Final MVP with proven, simple, and scalable approach

The current version represents a "start simple, iterate fast, scale smart" philosophy, focusing on core value delivery with room for future enhancement.