<div align="center">

<img src="public/Evaluo.png" alt="Evaluo Logo" width="160"/>

# Evaluo

**Fair, structured, and transparent peer assessment for academic collaboration.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-4CAF50?style=flat-square&logo=android&logoColor=white)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Decoupled-FF6F00?style=flat-square)](#architecture)
[![Status](https://img.shields.io/badge/Status-In%20Development-FFC107?style=flat-square)](#status)
[![License](https://img.shields.io/badge/License-Academic-9C27B0?style=flat-square)](#)

[Overview](#-overview) · [Features](#-features) · [Architecture](#-architecture) · [Design](#-design) · [References](#-existing-solutions)

</div>

---

## Descripción de la aplicación

**Evaluo** es una aplicación móvil desarrollada en Flutter para gestionar procesos de **evaluación entre pares** en cursos universitarios. La plataforma centraliza en una sola app los flujos de estudiantes y docentes, permitiendo crear actividades de evaluación, diligenciar valoraciones por compañeros y consultar resultados con métricas accionables.

### Propósito

Mejorar la transparencia, trazabilidad y equidad en el trabajo colaborativo académico, facilitando que:

- Los estudiantes evalúen a sus compañeros con criterios claros y homogéneos.
- Los docentes monitoreen el desempeño individual y grupal con evidencia cuantitativa y cualitativa.
- El proceso de evaluación se integre al ciclo normal del curso con autenticación segura y datos persistentes.

### Funcionalidades principales

- **Autenticación y gestión de sesión por roles**
  - Inicio de sesión, registro y validación de sesión.
  - Separación de experiencia para estudiante y docente desde el acceso principal.

- **Vista de inicio para estudiante**
  - Consulta de cursos inscritos.
  - Visualización de evaluaciones activas pendientes.
  - Filtrado de evaluaciones ya respondidas para evitar duplicados.

- **Vista de inicio para docente**
  - Consulta de cursos asignados.
  - Resumen de cantidad de cursos, estudiantes y evaluaciones activas por curso.

- **Gestión de cursos y grupos**
  - Consulta de evaluaciones y categorías de grupo por curso.
  - Importación de grupos desde archivos CSV.

- **Creación de evaluaciones**
  - Configuración de nombre, curso, categoría de grupo, fecha límite y visibilidad (pública/privada).
  - Actualización de información del curso tras crear una evaluación.

- **Formulario de coevaluación**
  - Evaluación por pares del mismo grupo.
  - Criterios estructurados: puntualidad, contribuciones, compromiso y actitud.
  - Escala de calificación y campo de comentarios opcionales.
  - Envío de respuestas por cada compañero evaluado.

- **Analíticas y resultados**
  - Para estudiantes: promedio por criterio, promedio general y comentarios recibidos.
  - Para docentes: métricas agregadas por actividad, por grupo y por estudiante, con detalle de comentarios.

- **Soporte técnico de datos**
  - Consumo de API con manejo de token y refresco automático de sesión.
  - Caché local por módulos para mejorar tiempos de carga.
  - Cierre automático de evaluaciones vencidas según fecha límite.

### Alcance

Evaluo está orientada a contextos académicos de educación superior donde se requiere evaluación de trabajo en equipo con seguimiento docente. En su alcance actual, la aplicación cubre el ciclo de autenticación de usuarios, consulta de cursos y evaluaciones por rol, configuración e importación de grupos, creación y diligenciamiento de evaluaciones entre pares, y consulta de resultados analíticos para estudiantes y docentes.

No busca reemplazar un LMS completo, sino complementar el curso con un módulo especializado de coevaluación estructurada y análisis de desempeño.

## Demo Videos

<div align="center">

<a href="https://youtu.be/TBtgmB99Puo">
  <img src="https://img.youtube.com/vi/TBtgmB99Puo/0.jpg" width="250"/>
</a>

<a href="https://youtu.be/ZaoQafAAg70">
  <img src="https://img.youtube.com/vi/ZaoQafAAg70/0.jpg" width="250"/>
</a>

<a href="https://youtu.be/RP4_TutqDlw">
  <img src="https://img.youtube.com/vi/RP4_TutqDlw/0.jpg" width="250"/>
</a>

<a href="https://youtu.be/f__2SkOUjoc">
  <img src="https://img.youtube.com/vi/f__2SkOUjoc/0.jpg" width="250"/>
</a>

<br/>

<a href="https://youtu.be/t1gw3ovSucU">
  <img src="https://img.youtube.com/vi/t1gw3ovSucU/0.jpg" width="250"/>
</a>

<a href="https://youtu.be/zC7QQSviowg">
  <img src="https://img.youtube.com/vi/zC7QQSviowg/0.jpg" width="250"/>
</a>

</div>

## Overview

**Evaluo** is a mobile application built with **Flutter** that enables fair, structured peer assessment in collaborative academic environments. Designed for university courses, it allows students to evaluate teammates based on predefined criteria while giving instructors actionable insights into both group and individual performance.

> Built on real feedback from faculty at **Universidad del Norte**, Evaluo addresses transparency, accountability, and trust gaps in collaborative learning.

---

## Features

| Feature                  | Description                                                     |
| ------------------------ | --------------------------------------------------------------- |
| **Role-based Access**    | Single app with distinct flows for students and instructors     |
| **Structured Rubrics**   | Predefined evaluation criteria for consistent, fair assessments |
| **Performance Insights** | Detailed metrics on individual and group contributions          |
| **Team Management**      | Automatic group formation and contribution tracking             |

---

## Architecture

<div align="center">
  <img src="public/architecture.png" alt="Evaluo Architecture Diagram" width="700"/>
</div>

<br/>

Evaluo follows a **decoupled architecture** that separates frontend concerns from backend services, enabling:

- **Scalability** — independent scaling of frontend and backend layers
- **Maintainability** — clear separation of concerns across the codebase
- **Security** — role-based access control with properly secured endpoints
- **Flexibility** — backend services can evolve independently of the mobile client

> **Design decision:** A single unified application with role-based access was chosen over multiple independent apps to avoid duplicated business logic, reduce maintenance costs, and improve long-term scalability. This proposal was validated through interviews with faculty from the Systems Engineering Department at Universidad del Norte: Daniel Romero, Eduardo Angulo and Wilson Nieto.

---

## Design

The UI/UX was designed in Figma with a strong emphasis on clarity, accessibility, and ease of use for both students and instructors.

<div align="center">
  <img src="public/display1.png" alt="Screen 1" width="200"/>
  &nbsp;&nbsp;
  <img src="public/display2.png" alt="Screen 2" width="200"/>
  &nbsp;&nbsp;
  <img src="public/display3.png" alt="Screen 3" width="200"/>
  &nbsp;&nbsp;
  <img src="public/display4.png" alt="Screen 4" width="200"/>
</div>

<div align="center">

[![Figma](https://img.shields.io/badge/View%20in%20Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)](https://www.figma.com/design/o8v3NtkBwXjPmkTLGS7bFJ/Evaluo?node-id=0-1&t=kBaasNMpaH0JJzW8-1)

</div>

---

## Existing Solutions

Research into existing peer assessment platforms informed Evaluo's design and feature set.

<details>
<summary><strong>Kritik 360</strong> — AI-powered rubric generation & anonymous peer review</summary>
<br/>

An educational platform that enhances student engagement through peer-to-peer assessment with predefined rubrics. Its standout feature is an **AI-powered Course Creator** that generates assignments and rubrics from a syllabus upload. Anonymous evaluations reduce bias and promote objective feedback.

🔗 [kritik.io/kritik360](https://www.kritik.io/kritik360)

</details>

<details>
<summary><strong>FeedbackFruits</strong> — LMS-integrated peer assessment with AI-assisted feedback</summary>
<br/>

An LMS-integrated platform (Canvas, Brightspace) that streamlines peer assessment, self-evaluation, and structured feedback. Features AI-assisted feedback generation and automated workflows that reduce administrative workload significantly.

🔗 [feedbackfruits.com](https://feedbackfruits.com)

</details>

<details>
<summary><strong>Peerceptiv</strong> — Research-backed collaborative evaluation platform</summary>
<br/>

Supported by over two decades of academic research, Peerceptiv focuses on anonymous evaluation and measurement of individual contributions within team projects. Students assess peers on professionalism, communication, and work ethic.

🔗 [peerceptiv.com](https://peerceptiv.com)

</details>

---

## Status

Evaluo is currently under **active development** as an academic project. Contributions and feedback are welcome.

---

<div align="center">

Made with ❤️ at **Universidad del Norte**

</div>
